variable "domains_broker_alb_count" {
  default = 0
}

variable "domains_broker_rds_username" {
}

variable "domains_broker_rds_password" {
  sensitive = true
}

/* Broker internal load balancer */
resource "aws_lb" "domains_broker_internal" {
  name                       = "${var.stack_description}-domains-internal"
  subnets                    = [module.cf.services_subnet_az1, module.cf.services_subnet_az2]
  security_groups            = [module.stack.bosh_security_group]
  internal                   = true
  enable_deletion_protection = true
  access_logs {
    bucket  = module.log_bucket.elb_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_listener" "domains_broker_internal" {
  load_balancer_arn = aws_lb.domains_broker_internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.domains_broker_internal.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "domains_broker_internal" {
  name     = "${var.stack_description}-domains-internal"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.stack.vpc_id

  health_check {
    path = "/healthcheck"
  }
}

output "domains_broker_internal_dns_name" {
  value = aws_lb.domains_broker_internal.dns_name
}

output "domains_broker_internal_target_group" {
  value = aws_lb_target_group.domains_broker_internal.name
}

/* Broker database */
resource "aws_db_instance" "domains_broker" {
  db_name                     = "domains_broker"
  storage_type                = "gp3"
  allocated_storage           = 20
  instance_class              = "db.t3.small"
  username                    = var.domains_broker_rds_username
  password                    = var.domains_broker_rds_password
  engine                      = "postgres"
  engine_version              = var.domains_broker_rds_version
  db_subnet_group_name        = module.stack.rds_subnet_group
  skip_final_snapshot         = true
  final_snapshot_identifier   = "${var.stack_description}-domains-broker-final-snapshot"
  vpc_security_group_ids      = [module.stack.rds_postgres_security_group]
  allow_major_version_upgrade = true
  backup_retention_period     = 14
  storage_encrypted           = true
}

output "domains_broker_rds_username" {
  value = aws_db_instance.domains_broker.username
}

output "domains_broker_rds_password" {
  value     = aws_db_instance.domains_broker.password
  sensitive = true
}

output "domains_broker_rds_address" {
  value = aws_db_instance.domains_broker.address
}

output "domains_broker_rds_port" {
  value = aws_db_instance.domains_broker.port
}

/* new dedicated load balancer group */
module "dedicated_loadbalancer_group" {
  source            = "../../modules/external_domain_broker_loadbalancer_group"
  stack_description = var.stack_description

  subnets                              = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  security_groups                      = [module.stack.web_traffic_security_group]
  elb_bucket_name                      = module.log_bucket.elb_bucket_name
  waf_arn                              = module.cf.cf_uaa_waf_core_arn
  logstash_hosts                       = var.logstash_hosts
  vpc_id                               = module.stack.vpc_id
  domains_lbgroup_count                = var.domains_lbgroup_count
  wildcard_arn                         = data.aws_iam_server_certificate.wildcard.arn
  loadbalancer_forward_original_weight = var.loadbalancer_forward_original_weight
  loadbalancer_forward_new_weight      = var.loadbalancer_forward_new_weight
  aws_lb_listener_ssl_policy           = var.aws_lb_listener_ssl_policy
}

/* old domains broker alb */
resource "aws_lb" "domains_broker" {
  count = var.domains_broker_alb_count

  name                       = "${var.stack_description}-domains-${count.index}"
  subnets                    = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  security_groups            = [module.stack.web_traffic_security_group]
  ip_address_type            = "dualstack"
  idle_timeout               = 3600
  enable_deletion_protection = true
  access_logs {
    bucket  = module.log_bucket.elb_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_listener" "domains_broker_http" {
  count = var.domains_broker_alb_count

  load_balancer_arn = aws_lb.domains_broker[count.index].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.domains_broker_apps_https[count.index].arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.domains_broker_gr_apps_https[count.index].arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }
}

resource "aws_lb_listener" "domains_broker_https" {
  count = var.domains_broker_alb_count

  load_balancer_arn = aws_lb.domains_broker[count.index].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.aws_lb_listener_ssl_policy
  certificate_arn   = data.aws_iam_server_certificate.wildcard.arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.domains_broker_apps_https[count.index].arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.domains_broker_gr_apps_https[count.index].arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }
}

resource "aws_lb_listener_rule" "static_http" {
  count = var.domains_broker_alb_count

  listener_arn = aws_lb_listener.domains_broker_http[count.index].arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.domains_broker_challenge[count.index].arn
  }

  condition {
    path_pattern {
      values = ["/.well-known/acme-challenge/*"]
    }
  }
}

resource "aws_lb_listener_rule" "static_https" {
  count = var.domains_broker_alb_count

  listener_arn = aws_lb_listener.domains_broker_https[count.index].arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.domains_broker_challenge[count.index].arn
  }

  condition {
    path_pattern {
      values = ["/.well-known/acme-challenge/*"]
    }
  }
}

## MAX 10 HOSTS
resource "aws_lb_listener_rule" "domains_broker_logstash_listener_rule" {
  count = var.domains_broker_alb_count

  listener_arn = aws_lb_listener.domains_broker_https[count.index].arn

  action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.domains_broker_logstash_https[count.index].arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.domains_broker_gr_logstash_https[count.index].arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }

  condition {
    host_header {
      values = var.logstash_hosts
    }
  }
}

resource "aws_lb_target_group" "domains_broker_apps_https" {
  count = var.domains_broker_alb_count

  name     = "${var.stack_description}-domains-apps-https-${count.index}"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.stack.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 4
    interval            = 5
    port                = 81
    matcher             = 200
  }
}

resource "aws_lb_target_group" "domains_broker_logstash_https" {
  count = var.domains_broker_alb_count

  name     = "${var.stack_description}-domains-logstash-${count.index}"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.stack.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 4
    interval            = 5
    port                = 81
    matcher             = 200
  }
}

resource "aws_lb_target_group" "domains_broker_gr_apps_https" {
  count = var.domains_broker_alb_count

  name     = "${var.stack_description}-domains-gapps-https${count.index}"
  port     = 10443
  protocol = "HTTPS"
  vpc_id   = module.stack.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    port                = 8443
    timeout             = 4
    unhealthy_threshold = 3
    matcher             = 200
    protocol            = "HTTPS"
    path                = "/health"
  }
}

resource "aws_lb_target_group" "domains_broker_gr_logstash_https" {
  count = var.domains_broker_alb_count

  name     = "${var.stack_description}-domains-glogstash-${count.index}"
  port     = 10443
  protocol = "HTTPS"
  vpc_id   = module.stack.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    port                = 8443
    timeout             = 4
    unhealthy_threshold = 3
    matcher             = 200
    protocol            = "HTTPS"
    path                = "/health"
  }
}

resource "aws_lb_target_group" "domains_broker_challenge" {
  count = var.domains_broker_alb_count

  name     = "${var.stack_description}-domains-acme-${count.index}"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = module.stack.vpc_id

  health_check {
    path = "/health"
  }
}

resource "aws_wafv2_web_acl_association" "domain_waf" {
  count = var.domains_broker_alb_count

  resource_arn = aws_lb.domains_broker[count.index].arn
  web_acl_arn  = module.cf.cf_uaa_waf_core_arn
}

output "domains_broker_alb_names" {
  value = aws_lb.domains_broker.*.name
}

output "domains_broker_target_group_apps_https_names" {
  value = aws_lb_target_group.domains_broker_apps_https.*.name
}

output "domains_broker_target_group_challenge_names" {
  value = aws_lb_target_group.domains_broker_challenge.*.name
}

output "domains_broker_listener_arns" {
  value = aws_lb_listener.domains_broker_http.*.arn
}

/* n.b. this bucket is used for:
   - original domains broker
   - original cdn broker
   - new domains + cdn broker
 */
resource "aws_s3_bucket" "domains_bucket" {
  bucket = "${var.stack_description}-domains-broker-challenge"
}

resource "aws_s3_bucket_policy" "domains_bucket_policy" {
  bucket = aws_s3_bucket.domains_bucket.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowRead",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:${data.aws_partition.current.partition}:s3:::${var.stack_description}-domains-broker-challenge/*"
    }
  ]
}
EOF

}

output "challenge_bucket" {
  value = aws_s3_bucket.domains_bucket.id
}

output "challenge_bucket_domain_name" {
  value = aws_s3_bucket.domains_bucket.bucket_domain_name
}

/* IAM resources */
resource "aws_iam_instance_profile" "domains_broker" {
  name = "${var.stack_description}-domain-broker"
  role = aws_iam_role.domains_broker.name
}

resource "aws_iam_role" "domains_broker" {
  name               = "${var.stack_description}-domains-broker"
  path               = "/bosh-passed/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "domains_broker" {
  name   = "${var.stack_description}-domains-broker"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:UploadServerCertificate",
        "iam:DeleteServerCertificate"
      ],
      "Resource": [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/domains/${var.stack_description}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:${data.aws_partition.current.partition}:s3:::${var.stack_description}-domains-broker-challenge/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF

}

resource "aws_iam_user" "legacy_domain_certificate_renewer" {
  name = "legacy_domain_certificate_renewer_${var.stack_description}"
}

resource "aws_iam_access_key" "legacy_domain_certificate_renewer_key_v1" {
  user = aws_iam_user.legacy_domain_certificate_renewer.name
}

resource "aws_iam_access_key" "legacy_domain_certificate_renewer_key_v2" {
  user = aws_iam_user.legacy_domain_certificate_renewer.name
}

resource "aws_iam_policy_attachment" "domains_broker" {
  name       = "${var.stack_description}-domains-broker"
  policy_arn = aws_iam_policy.domains_broker.arn
  roles = [
    aws_iam_role.domains_broker.name,
  ]
  users = [
    aws_iam_user.legacy_domain_certificate_renewer.name
  ]
}

output "legacy_domain_certificate_renewer_username" {
  value = aws_iam_user.legacy_domain_certificate_renewer.name
}

output "legacy_domain_certificate_renwer_access_key_id_prev" {
  value = aws_iam_access_key.legacy_domain_certificate_renewer_key_v1.id
}

output "legacy_domain_certificate_renewer_secret_access_key_prev" {
  value     = aws_iam_access_key.legacy_domain_certificate_renewer_key_v1.secret
  sensitive = true
}

output "legacy_domain_certificate_renewer_access_key_id_curr" {
  value = aws_iam_access_key.legacy_domain_certificate_renewer_key_v2.id
}

output "legacy_domain_certificate_renewer_secret_access_key_curr" {
  value     = aws_iam_access_key.legacy_domain_certificate_renewer_key_v2.secret
  sensitive = true
}

output "domains_broker_profile" {
  value = aws_iam_instance_profile.domains_broker.name
}

data "dns_a_record_set" "domains-internal-lb_ips" {
  host = aws_lb.domains_broker_internal.dns_name
}

locals {
  services-az1-net = module.cf.services_cidr_1
  services-az2-net = module.cf.services_cidr_2
  domain-lb-ips    = data.dns_a_record_set.domains-internal-lb_ips.addrs
}

output "domains-internal-ip-az1" {
  value = cidrhost(local.services-az1-net, 0) == cidrhost("${local.domain-lb-ips[0]}/24", 0) ? local.domain-lb-ips[0] : local.domain-lb-ips[1]
}
output "domains-internal-ip-az2" {
  value = cidrhost(local.services-az2-net, 0) == cidrhost("${local.domain-lb-ips[1]}/24", 0) ? local.domain-lb-ips[1] : local.domain-lb-ips[0]
}

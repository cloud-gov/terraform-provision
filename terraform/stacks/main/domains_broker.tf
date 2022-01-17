variable "domains_broker_alb_count" {
  default = 0
}

variable "domains_broker_rds_username" {
}

variable "domains_broker_rds_password" {
}

variable "challenge_bucket" {
}

variable "iam_cert_prefix" {
  default = "/domains/*"
}

variable "alb_prefix" {
  default = "domains-*"
}

/* Broker internal load balancer */
resource "aws_lb" "domains_broker_internal" {
  name    = "${var.stack_description}-domains-internal"
  subnets = [module.cf.services_subnet_az1, module.cf.services_subnet_az2]
  security_groups = [module.stack.bosh_security_group]
  internal        = true
  access_logs {
    bucket  = var.log_bucket_name
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
  name                 = "domains_broker"
  storage_type         = "gp2"
  allocated_storage    = 10
  instance_class       = "db.t2.micro"
  username             = var.domains_broker_rds_username
  password             = var.domains_broker_rds_password
  engine               = "postgres"
  engine_version       = var.domains_broker_rds_version
  db_subnet_group_name = module.stack.rds_subnet_group
  vpc_security_group_ids = [module.stack.rds_postgres_security_group]
}

output "domains_broker_rds_username" {
  value = aws_db_instance.domains_broker.username
}

output "domains_broker_rds_password" {
  value = aws_db_instance.domains_broker.password
}

output "domains_broker_rds_address" {
  value = aws_db_instance.domains_broker.address
}

output "domains_broker_rds_port" {
  value = aws_db_instance.domains_broker.port
}

/* old domains broker alb */
resource "aws_lb" "domains_broker" {
  count = var.domains_broker_alb_count

  name    = "${var.stack_description}-domains-${count.index}"
  subnets = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  security_groups = [module.stack.web_traffic_security_group]
  ip_address_type = "dualstack"
  idle_timeout    = 3600
  access_logs {
    bucket  = var.log_bucket_name
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
    target_group_arn = aws_lb_target_group.domains_broker_apps_https[count.index].arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "domains_broker_https" {
  count = var.domains_broker_alb_count

  load_balancer_arn = aws_lb.domains_broker[count.index].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_iam_server_certificate.wildcard.arn

  default_action {
    target_group_arn = aws_lb_target_group.domains_broker_apps_https[count.index].arn
    type             = "forward"
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

resource "aws_wafv2_regex_pattern_set" "jndi_regex_domains" {
  name        = "${var.stack_description}-waf-jndi-regex_domains"
  description = "DOMAINS Regex Pattern Set for JNDI"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "(\\$|\\%24)(\\{|\\%7[bB])jndi(:|\\%3[aA])"
  }
}

resource "aws_wafv2_web_acl" "cf_domains_waf_acl" {
  name        = "${var.stack_description}-cf-domains-waf-acl"
  description = "UAA ELB WAF Rules"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-KnownBadInputsRuleSet"
    priority = 5

    override_action {
      none{}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-Domains-KnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "cloudfront-only-access"
    priority = 1
    action {
      count {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-Domains-KnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            text_transformation {
              priority = 1
              type = "NONE"
            }
            field_to_match {
              single_header {
                name = var.cloudfront_access_header_name
              }
            }
            positional_constraint = "EXACTLY"
            search_string = var.cloudfront_access_header_value
          }
        }
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string = "/robots.txt"
            text_transformation {
              priority = 1
              type = "NONE"
            }
            field_to_match {
              uri_path {}
            }
          }
        }
      }
    }


  }

  rule {
    name     = "AWSManagedRule-CoreRuleSet"
    priority = 20

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-Domains-ManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-cf-domains-waf-metric"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "domain_waf" {
  count = var.domains_broker_alb_count

  resource_arn = aws_lb.domains_broker[count.index].arn
  web_acl_arn  = aws_wafv2_web_acl.cf_domains_waf_acl.arn
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
  bucket = var.challenge_bucket
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
      "Resource": "arn:${data.aws_partition.current.partition}:s3:::${var.challenge_bucket}/*"
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
        "iam:ListServerCertificates",
        "iam:GetServerCertificate",
        "iam:UploadServerCertificate",
        "iam:DeleteServerCertificate"
      ],
      "Resource": [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate${var.iam_cert_prefix}"
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
        "arn:${data.aws_partition.current.partition}:s3:::${var.challenge_bucket}/*"
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
  value = ""
}

output "legacy_domain_certificate_renewer_secret_access_key_prev" {
  value = ""
}

output "legacy_domain_certificate_renewer_access_key_id_curr" {
  value = aws_iam_access_key.legacy_domain_certificate_renewer_key_v1.id
}

output "legacy_domain_certificate_renewer_secret_access_key_curr" {
  value = aws_iam_access_key.legacy_domain_certificate_renewer_key_v1.secret
}

output "domains_broker_profile" {
  value = aws_iam_instance_profile.domains_broker.name
}

variable "domains_broker_alb_count" {
  default = 0
}
variable "domains_broker_rds_username" {}
variable "domains_broker_rds_password" {}
variable "domain_broker_v2_rds_username" {}
variable "domain_broker_v2_rds_password" {}
variable "domain_broker_v2_alb_count" {
  default = 0
}
variable "challenge_bucket" {}
variable "iam_cert_prefix" {
  default = "/domains/*"
}
variable "alb_prefix" {
  default = "domains-*"
}

/* Broker internal load balancer */
resource "aws_lb" "domains_broker_internal" {
  name            = "${var.stack_description}-domains-internal"
  subnets         = ["${module.cf.services_subnet_az1}", "${module.cf.services_subnet_az2}"]
  security_groups = ["${module.stack.bosh_security_group}"]
  internal        = true
  access_logs = {
    bucket = "${var.log_bucket_name}"
    prefix = "${var.stack_description}"
  }
}

resource "aws_lb_listener" "domains_broker_internal" {
  load_balancer_arn = "${aws_lb.domains_broker_internal.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.domains_broker_internal.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "domains_broker_internal" {
  name     = "${var.stack_description}-domains-internal"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"

  health_check {
    path = "/healthcheck"
  }
}

output "domains_broker_internal_dns_name" {
  value = "${aws_lb.domains_broker_internal.dns_name}"
}
output "domains_broker_internal_target_group" {
  value = "${aws_lb_target_group.domains_broker_internal.name}"
}

/* Broker database */
resource "aws_db_instance" "domains_broker" {
  name                   = "domains_broker"
  storage_type           = "gp2"
  allocated_storage      = 10
  instance_class         = "db.t2.micro"
  username               = "${var.domains_broker_rds_username}"
  password               = "${var.domains_broker_rds_password}"
  engine                 = "postgres"
  db_subnet_group_name   = "${module.stack.rds_subnet_group}"
  vpc_security_group_ids = ["${module.stack.rds_postgres_security_group}"]
}

output "domains_broker_rds_username" {
  value = "${aws_db_instance.domains_broker.username}"
}
output "domains_broker_rds_password" {
  value = "${aws_db_instance.domains_broker.password}"
}
output "domains_broker_rds_address" {
  value = "${aws_db_instance.domains_broker.address}"
}
output "domains_broker_rds_port" {
  value = "${aws_db_instance.domains_broker.port}"
}

/* old domains broker alb */
resource "aws_lb" "domains_broker" {
  count = "${var.domains_broker_alb_count}"

  name            = "${var.stack_description}-domains-${count.index}"
  subnets         = ["${module.stack.public_subnet_az1}", "${module.stack.public_subnet_az2}"]
  security_groups = ["${module.stack.web_traffic_security_group}"]
  ip_address_type = "dualstack"
  idle_timeout    = 3600
  access_logs = {
    bucket = "${var.log_bucket_name}"
    prefix = "${var.stack_description}"
  }
}

resource "aws_lb_listener" "domains_broker_http" {
  count = "${var.domains_broker_alb_count}"

  load_balancer_arn = "${aws_lb.domains_broker.*.arn[count.index]}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.domains_broker_apps.*.arn[count.index]}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "domains_broker_https" {
  count = "${var.domains_broker_alb_count}"

  load_balancer_arn = "${aws_lb.domains_broker.*.arn[count.index]}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${data.aws_iam_server_certificate.wildcard.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.domains_broker_apps.*.arn[count.index]}"
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "static_http" {
  count = "${var.domains_broker_alb_count}"

  listener_arn = "${aws_lb_listener.domains_broker_http.*.arn[count.index]}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.domains_broker_challenge.*.arn[count.index]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/.well-known/acme-challenge/*"]
  }
}

resource "aws_lb_listener_rule" "static_https" {
  count = "${var.domains_broker_alb_count}"

  listener_arn = "${aws_lb_listener.domains_broker_https.*.arn[count.index]}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.domains_broker_challenge.*.arn[count.index]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/.well-known/acme-challenge/*"]
  }
}

resource "aws_lb_target_group" "domains_broker_apps" {
  count = "${var.domains_broker_alb_count}"

  name     = "${var.stack_description}-domains-apps-${count.index}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"

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
  count = "${var.domains_broker_alb_count}"

  name     = "${var.stack_description}-domains-acme-${count.index}"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"

  health_check {
    path = "/health"
  }
}

output "domains_broker_alb_names" {
  value = "${aws_lb.domains_broker.*.name}"
}
output "domains_broker_target_group_apps_names" {
  value = "${aws_lb_target_group.domains_broker_apps.*.name}"
}
output "domains_broker_target_group_challenge_names" {
  value = "${aws_lb_target_group.domains_broker_challenge.*.name}"
}
output "domains_broker_listener_arns" {
  value = "${aws_lb_listener.domains_broker_http.*.arn}"
}

/* new broker ALB */

resource "aws_iam_user" "domain_broker_v2" {
  name = "domain_broker_v2_${var.stack_description}"
  path = "/domain-broker-v2/"
}

resource "aws_iam_access_key" "domain_broker_v2_access_key" {
  user = "${aws_iam_user.domain_broker_v2.name}"
}

resource "aws_iam_user_policy" "domain_broker_v2_policy" {
  name   = "domain_broker_v2_policy"
  user   = "${aws_iam_user.domain_broker_v2.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancer"
            ],
            "Effect": "Deny",
            "Resource": "*"
        },
        {
            "Action": [
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:Modify*",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveListenerCertificates"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "iam:DeleteServerCertificate",
                "iam:GetServerCertificate",
                "iam:ListServerCertificates",
                "iam:UpdateServerCertificate",
                "iam:UploadServerCertificate"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_lb" "domain_broker_v2" {
  count = "${var.domain_broker_v2_alb_count}"

  name            = "${var.stack_description}-domains-${count.index}"
  subnets         = ["${module.stack.public_subnet_az1}", "${module.stack.public_subnet_az2}"]
  security_groups = ["${module.stack.web_traffic_security_group}"]
  ip_address_type = "dualstack"
  idle_timeout    = 3600
  access_logs = {
    bucket = "${var.log_bucket_name}"
    prefix = "${var.stack_description}"
  }
}

resource "aws_lb_listener" "domain_broker_v2_http" {
  count = "${var.domain_broker_v2_alb_count}"

  load_balancer_arn = "${aws_lb.domain_broker_v2.*.arn[count.index]}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.domain_broker_v2_apps.*.arn[count.index]}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "domain_broker_v2_https" {
  count = "${var.domain_broker_v2_alb_count}"

  load_balancer_arn = "${aws_lb.domain_broker_v2.*.arn[count.index]}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${data.aws_iam_server_certificate.wildcard.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.domain_broker_v2_apps.*.arn[count.index]}"
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "domain_broker_v2static_http" {
  count = "${var.domain_broker_v2_alb_count}"

  listener_arn = "${aws_lb_listener.domain_broker_v2_http.*.arn[count.index]}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.domain_broker_v2_challenge.*.arn[count.index]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/.well-known/acme-challenge/*"]
  }
}

resource "aws_lb_listener_rule" "domain_broker_v2_static_https" {
  count = "${var.domain_broker_v2_alb_count}"

  listener_arn = "${aws_lb_listener.domain_broker_v2_https.*.arn[count.index]}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.domain_broker_v2_challenge.*.arn[count.index]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/.well-known/acme-challenge/*"]
  }
}

resource "aws_lb_target_group" "domain_broker_v2_apps" {
  count = "${var.domain_broker_v2_alb_count}"

  name     = "${var.stack_description}-domains-apps-${count.index}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 4
    interval            = 5
    port                = 81
    matcher             = 200
  }
}

resource "aws_lb_target_group" "domain_broker_v2_challenge" {
  count = "${var.domain_broker_v2_alb_count}"

  name     = "${var.stack_description}-domains-acme-${count.index}"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"

  health_check {
    path = "/health"
  }
}

resource "aws_db_instance" "domain_broker_v2" {
  name                   = "domain_broker_v2"
  storage_type           = "gp2"
  allocated_storage      = 10
  instance_class         = "db.t2.micro"
  username               = "${var.domain_broker_v2_rds_username}"
  password               = "${var.domain_broker_v2_rds_password}"
  engine                 = "postgres"
  db_subnet_group_name   = "${module.stack.rds_subnet_group}"
  vpc_security_group_ids = ["${module.stack.rds_postgres_security_group}"]
}

output "domain_broker_v2_rds_username" {
  value = "${aws_db_instance.domain_broker_v2.username}"
}
output "domain_broker_v2_rds_password" {
  value = "${aws_db_instance.domain_broker_v2.password}"
}
output "domain_broker_v2_rds_address" {
  value = "${aws_db_instance.domain_broker_v2.address}"
}
output "domain_broker_v2_rds_port" {
  value = "${aws_db_instance.domain_broker_v2.port}"
}

output "domain_broker_v2_alb_names" {
  value = "${aws_lb.domain_broker_v2.*.name}"
}
output "domain_broker_v2_target_group_apps_names" {
  value = "${aws_lb_target_group.domain_broker_v2_apps.*.name}"
}
output "domain_broker_v2_target_group_challenge_names" {
  value = "${aws_lb_target_group.domain_broker_v2_challenge.*.name}"
}
output "domain_broker_v2_listener_arns" {
  value = "${aws_lb_listener.domain_broker_v2_http.*.arn}"
}
output "domain_broker_v2_access_key_id" {
  value = "${aws_iam_access_key.domain_broker_v2_access_key.id}"
}
output "domain_broker_v2_secret_access_key" {
  value = "${aws_iam_access_key.domain_broker_v2_access_key.secret}"
}
/* end new broker alb config */

/* n.b. this bucket is used for:
   - original domains broker
   - original cdn broker
   - new domains + cdn broker
 */
resource "aws_s3_bucket" "domains_bucket" {
  bucket = "${var.challenge_bucket}"
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
  value = "${aws_s3_bucket.domains_bucket.id}"
}
output "challenge_bucket_domain_name" {
  value = "${aws_s3_bucket.domains_bucket.bucket_domain_name}"
}

/* IAM resources */
resource "aws_iam_instance_profile" "domains_broker" {
  name = "${var.stack_description}-domain-broker"
  role = "${aws_iam_role.domains_broker.name}"
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

resource "aws_iam_policy_attachment" "domains_broker" {
  name       = "${var.stack_description}-domains-broker"
  policy_arn = "${aws_iam_policy.domains_broker.arn}"
  roles = [
    "${aws_iam_role.domains_broker.name}"
  ]
}

output "domains_broker_profile" {
  value = "${aws_iam_instance_profile.domains_broker.name}"
}

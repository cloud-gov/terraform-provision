/* new broker ALB */

// =====================================
// OK, so DO NOT DELETE THESE RESOURCES
// =====================================
//
// ...unless you're prepared to spend ~2 days doing terraform state surgery.
//
// https://docs.google.com/document/d/19LDEX8ac46JkPgoJUoSAJCf2B0K5D_QpX6O1IdO8w7Q/edit
//
// See also this github issue, outlining a potential checklist:
//
// https://github.com/cloud-gov/cg-provision/issues/735
//
// Basically, these resources are pointed at the same AWS resources (LB,
// listeners, etc) as the other domains_broker resources in this directory.
// We attempted to delete these resources.  `terraform plan` looked good, but
// `terraform apply` got real mad.

variable "domain_broker_v2_rds_username" {
}

variable "domain_broker_v2_rds_password" {
}

variable "domain_broker_v2_alb_count" {
  default = 0
}

// DO NOT DELETE (see above)
resource "aws_iam_user" "domain_broker_v2" {
  name = "domain_broker_v2_${var.stack_description}"
  path = "/domain-broker-v2/"
}

// DO NOT DELETE (see above)
resource "aws_iam_access_key" "domain_broker_v2_access_key" {
  user = aws_iam_user.domain_broker_v2.name
}

// DO NOT DELETE (see above)
resource "aws_iam_user_policy" "domain_broker_v2_policy" {
  name = "domain_broker_v2_policy"
  user = aws_iam_user.domain_broker_v2.name

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

// DO NOT DELETE (see above)
resource "aws_lb" "domain_broker_v2" {
  count = var.domain_broker_v2_alb_count

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

// DO NOT DELETE (see above)
resource "aws_lb_listener" "domain_broker_v2_http" {
  count = var.domain_broker_v2_alb_count

  load_balancer_arn = aws_lb.domain_broker_v2[count.index].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.domain_broker_v2_apps[count.index].arn
    type             = "forward"
  }
}

// DO NOT DELETE (see above)
resource "aws_lb_listener" "domain_broker_v2_https" {
  count = var.domain_broker_v2_alb_count

  load_balancer_arn = aws_lb.domain_broker_v2[count.index].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_iam_server_certificate.wildcard.arn

  default_action {
    type = "forward"
    forward {
      stickiness {
        duration = 1
        enabled  = false
        }
      target_group {
        arn = aws_lb_target_group.domain_broker_v2_apps[count.index].arn
        weight = 0
        }
        target_group {
        arn = aws_lb_target_group.domain_broker_v2_apps_https[count.index].arn
        weight = 100
        }
      }
  }
}

// DO NOT DELETE (see above)
resource "aws_lb_listener_rule" "domain_broker_v2static_http" {
  count = var.domain_broker_v2_alb_count

  listener_arn = aws_lb_listener.domain_broker_v2_http[count.index].arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.domain_broker_v2_challenge[count.index].arn
  }

  condition {
    path_pattern {
      values = ["/.well-known/acme-challenge/*"]
    }
  }
}

// DO NOT DELETE (see above)
resource "aws_lb_listener_rule" "domain_broker_v2_static_https" {
  count = var.domain_broker_v2_alb_count

  listener_arn = aws_lb_listener.domain_broker_v2_https[count.index].arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.domain_broker_v2_challenge[count.index].arn
  }

  condition {
    path_pattern {
      values = ["/.well-known/acme-challenge/*"]
    }
  }
}

// DO NOT DELETE (see above)
resource "aws_lb_target_group" "domain_broker_v2_apps" {
  count = var.domain_broker_v2_alb_count

  name     = "${var.stack_description}-domains-apps-${count.index}"
  port     = 80
  protocol = "HTTP"
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

resource "aws_lb_target_group" "domain_broker_v2_apps_https" {
  count = var.domain_broker_v2_alb_count

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

// DO NOT DELETE (see above)
resource "aws_lb_target_group" "domain_broker_v2_challenge" {
  count = var.domain_broker_v2_alb_count

  name     = "${var.stack_description}-domains-acme-${count.index}"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = module.stack.vpc_id

  health_check {
    path = "/health"
  }
}

// DO NOT DELETE (see above)
resource "aws_db_instance" "domain_broker_v2" {
  name                 = "domain_broker_v2"
  storage_type         = "gp2"
  allocated_storage    = 10
  instance_class       = "db.t2.micro"
  username             = var.domain_broker_v2_rds_username
  password             = var.domain_broker_v2_rds_password
  engine               = "postgres"
  db_subnet_group_name = module.stack.rds_subnet_group
  vpc_security_group_ids = [module.stack.rds_postgres_security_group]
}

output "domain_broker_v2_rds_username" {
  value = aws_db_instance.domain_broker_v2.username
}

output "domain_broker_v2_rds_password" {
  value = aws_db_instance.domain_broker_v2.password
}

output "domain_broker_v2_rds_address" {
  value = aws_db_instance.domain_broker_v2.address
}

output "domain_broker_v2_rds_port" {
  value = aws_db_instance.domain_broker_v2.port
}

output "domain_broker_v2_alb_names" {
  value = aws_lb.domain_broker_v2.*.name
}

output "domain_broker_v2_target_group_apps_names" {
  value = aws_lb_target_group.domain_broker_v2_apps.*.name
}

output "domain_broker_v2_target_group_apps_https_names" {
  value = aws_lb_target_group.domain_broker_v2_apps_https.*.name
}

output "domain_broker_v2_target_group_challenge_names" {
  value = aws_lb_target_group.domain_broker_v2_challenge.*.name
}

output "domain_broker_v2_listener_arns" {
  value = aws_lb_listener.domain_broker_v2_http.*.arn
}

output "domain_broker_v2_access_key_id" {
  value = aws_iam_access_key.domain_broker_v2_access_key.id
}

output "domain_broker_v2_secret_access_key" {
  value = aws_iam_access_key.domain_broker_v2_access_key.secret
}

/* end new broker alb config */

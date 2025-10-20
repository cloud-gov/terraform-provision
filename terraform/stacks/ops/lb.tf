# resource "aws_lb" "main" {
#   name            = "${var.stack_description}-main"
#   subnets         = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
#   security_groups = [module.stack.restricted_web_traffic_security_group]
#   ip_address_type = "dualstack"
#   idle_timeout    = 3600
#   access_logs {
#     bucket  = module.log_bucket.elb_bucket_name
#     prefix  = var.stack_description
#     enabled = true
#   }
#   enable_deletion_protection = false
# }

# resource "aws_lb" "opsuaa" {
#   name                       = "${var.stack_description}-opsuaa"
#   subnets                    = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
#   security_groups            = [module.stack.restricted_web_traffic_security_group]
#   ip_address_type            = "dualstack"
#   idle_timeout               = 3600
#   enable_deletion_protection = false
#   access_logs {
#     bucket  = var.log_bucket_name
#     prefix  = var.stack_description
#     enabled = true
#   }
# }

resource "aws_lb" "ops" {
  name            = "${var.stack_description}-ops"
  subnets         = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  security_groups = [module.stack.restricted_web_traffic_security_group]
  ip_address_type = "dualstack"
  idle_timeout    = 3600
  access_logs {
    bucket  = module.log_bucket.elb_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
  enable_deletion_protection = true
}

resource "aws_lb_listener" "ops" {
  load_balancer_arn = aws_lb.ops.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.aws_lb_listener_ssl_policy
  certificate_arn   = data.aws_iam_server_certificate.wildcard.arn

  default_action {
    type = "forward"
    forward {
      stickiness {
        enabled  = true
        duration = 60
      }
      target_group {
        arn    = aws_lb_target_group.opsuaa_target.arn
        weight = 10
      }
      target_group {
        arn    = aws_lb_target_group.dummy.arn
        weight = 999
      }
    }
  }
}

resource "aws_lb_target_group" "dummy" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.stack.vpc_id
  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
}

resource "aws_lb_target_group" "opsuaa_target" {
  name     = "${var.stack_description}-opsuaa"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = module.stack.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 61
    timeout             = 60
    unhealthy_threshold = 3
    path                = "/healthz"
    matcher             = 200
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
}


# resource "aws_lb_listener_rule" "nessus_listener_rule" {
#   listener_arn = aws_lb_listener.ops.arn

#   action {
#     type = "authenticate-oidc"
#     authenticate_oidc {
#       authorization_endpoint     = "https://${var.opslogin_hostname}/oauth/authorize"
#       client_id                  = var.nessus_oidc_client
#       client_secret              = var.nessus_oidc_client_secret
#       issuer                     = "https://${var.opslogin_hostname}/oauth/token"
#       token_endpoint             = "https://${var.opslogin_hostname}/oauth/token"
#       user_info_endpoint         = "https://${var.opslogin_hostname}/userinfo"
#       on_unauthenticated_request = "authenticate"
#     }
#   }
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.nessus_target.arn
#   }

#   condition {
#     host_header {
#       values = var.nessus_hosts
#     }
#   }
# }

# resource "aws_lb_target_group" "nessus_target" {
#   name     = "${var.stack_description}-nessus"
#   port     = 8834
#   protocol = "HTTPS"
#   vpc_id   = module.stack.vpc_id

#   health_check {
#     protocol            = "HTTPS"
#     healthy_threshold   = 2
#     interval            = 61
#     timeout             = 60
#     unhealthy_threshold = 3
#     matcher             = 200
#   }
# }



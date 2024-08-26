resource "aws_lb_target_group" "prometheus_target" {
  name     = "${var.stack_description}-prometheus"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    path                = "/ping"
    timeout             = 4
    unhealthy_threshold = 3
    matcher             = 200
  }
}

resource "aws_lb_listener_rule" "prometheus_listener_rule" {
  count = length(var.hosts)

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_target.arn
  }

  condition {
    host_header {
      values = [element(var.hosts, count.index)]
    }
  }
}

resource "aws_lb_target_group" "doomsday_target" {
  name     = "${var.stack_description}-doomsday"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    path                = "/"
    timeout             = 4
    unhealthy_threshold = 3
    matcher             = 200
  }
}

resource "aws_lb_listener_rule" "doomsday_listener_rule" {
  listener_arn = var.listener_arn

  action {
    type = "authenticate-oidc"
    authenticate_oidc {
      # https://opslogin.fr.cloud.gov/.well-known/openid-configuration
      authorization_endpoint     = "https://${var.opslogin_hostname}/oauth/authorize"
      client_id                  = var.doomsday_oidc_client
      client_secret              = var.doomsday_oidc_client_secret
      issuer                     = "https://${var.opslogin_hostname}/oauth/token"
      token_endpoint             = "https://${var.opslogin_hostname}/oauth/token"
      user_info_endpoint         = "https://${var.opslogin_hostname}/userinfo"
      on_unauthenticated_request = "authenticate"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.doomsday_target.arn
  }

  condition {
    host_header {
      values = ["doomsday.fr*.cloud.gov"]
    }
  }
}

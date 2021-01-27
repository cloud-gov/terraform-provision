resource "aws_lb" "opsuaa" {
  name    = "${var.stack_description}-opsuaa"
  subnets = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  security_groups = [module.stack.restricted_web_traffic_security_group]
  ip_address_type = "dualstack"
  idle_timeout    = 3600
  access_logs {
    bucket  = var.log_bucket_name
    prefix  = var.stack_description
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

resource "aws_lb_listener" "opsuaa_listener" {
  load_balancer_arn = aws_lb.opsuaa.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_iam_server_certificate.wildcard_production.arn

  default_action {
    target_group_arn = aws_lb_target_group.opsuaa_target.arn
    type             = "forward"
  }
}


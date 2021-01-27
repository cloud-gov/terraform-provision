resource "aws_lb" "cf_apps" {
  name            = "${var.stack_description}-cloudfoundry-apps"
  subnets         = var.elb_subnets
  security_groups = var.elb_security_groups
  ip_address_type = "dualstack"
  idle_timeout    = 3600
  access_logs {
    bucket  = var.log_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_target_group" "cf_apps_target" {
  name     = "${var.stack_description}-cf-apps"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    port                = 81
    timeout             = 4
    unhealthy_threshold = 3
    matcher             = 200
  }
}

resource "aws_lb_listener" "cf_apps" {
  load_balancer_arn = aws_lb.cf_apps.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.elb_apps_cert_id

  default_action {
    target_group_arn = aws_lb_target_group.cf_apps_target.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "cf_apps_http" {
  load_balancer_arn = aws_lb.cf_apps.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cf_apps_target.arn
    type             = "forward"
  }
}


resource "aws_lb" "opsuaa" {
  name                       = "${var.stack_description}-opsuaa"
  subnets                    = module.stack.public_subnet_ids
  security_groups            = [module.stack.restricted_web_traffic_security_group]
  ip_address_type            = "dualstack"
  idle_timeout               = 3600
  enable_deletion_protection = true
  access_logs {
    bucket  = module.log_bucket.elb_bucket_name
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
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
  certificate_arn   = data.aws_iam_server_certificate.wildcard_production.arn

  default_action {
    target_group_arn = aws_lb_target_group.opsuaa_target.arn
    type             = "forward"
  }
}

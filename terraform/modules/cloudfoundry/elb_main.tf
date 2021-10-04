resource "aws_lb" "cf" {
  name            = "${var.stack_description}-cloudfoundry"
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

resource "aws_lb_target_group" "cf_target" {
  name     = "${var.stack_description}-cf"
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

resource "aws_lb_target_group" "cf_target_https" {
  name     = "${var.stack_description}-cf-https"
  port     = 443
  protocol = "HTTPS"
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

resource "aws_lb_listener" "cf" {
  load_balancer_arn = aws_lb.cf.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.elb_main_cert_id

  default_action {
    type = "forward"
    forward {
      stickiness {
        duration = 1
        enabled  = false
        }
      target_group {
        arn = aws_lb_target_group.cf_target.arn
        weight = 50
      }
      target_group {
        arn = aws_lb_target_group.cf_target_https.arn
        weight = 50
      }
    }
  }
}

resource "aws_lb_listener" "cf_http" {
  load_balancer_arn = aws_lb.cf.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cf_target.arn
    type             = "forward"
  }
}

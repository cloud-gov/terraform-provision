resource "aws_lb" "cf_uaa" {
  name            = "${var.stack_description}-cloudfoundry-uaa"
  subnets         = var.elb_subnets
  security_groups = var.elb_security_groups
  ip_address_type = "dualstack"
  idle_timeout    = 3600

  enable_deletion_protection = true

  access_logs {
    bucket  = var.log_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_target_group" "cf_gr_uaa_target" {
  name     = "${var.stack_description}-cf-gr-uaa"
  port     = 10443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

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

resource "aws_lb_target_group" "cf_uaa_target" {
  name     = "${var.stack_description}-cf-uaa"
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

resource "aws_lb_listener" "cf_uaa" {
  load_balancer_arn = aws_lb.cf_uaa.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.aws_lb_listener_ssl_policy
  certificate_arn   = var.elb_main_cert_id

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.cf_uaa_target.arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.cf_gr_uaa_target.arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }
}

resource "aws_lb_listener" "cf_uaa_http" {
  load_balancer_arn = aws_lb.cf_uaa.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.cf_uaa_target.arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.cf_gr_uaa_target.arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }
}

data "aws_caller_identity" "current" {}

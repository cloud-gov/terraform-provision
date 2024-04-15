resource "aws_lb" "cf_apps" {
  name            = "${var.stack_description}-cloudfoundry-apps"
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

resource "aws_lb_target_group" "cf_apps_target_https" {
  name     = "${var.stack_description}-cf-apps-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  load_balancing_algorithm_type     = "weighted_random"
  load_balancing_anomaly_mitigation = "on"

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
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
  certificate_arn   = var.elb_apps_cert_id

  default_action {
    target_group_arn = aws_lb_target_group.cf_apps_target_https.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "cf_apps_http" {
  load_balancer_arn = aws_lb.cf_apps.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cf_apps_target_https.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "cf_logstash_target_https" {
  name     = "${var.stack_description}-cf-logstash-https"
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

resource "aws_lb_listener_rule" "logstash_listener_rule" {
  listener_arn = aws_lb_listener.cf_apps.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cf_logstash_target_https.arn
  }

  condition {
    host_header {
      values = [var.waf_hostname_0]
    }
  }
}

resource "aws_lb_listener_certificate" "pages" {
  for_each        = var.pages_cert_ids
  listener_arn    = aws_lb_listener.cf_apps.arn
  certificate_arn = each.key
}

resource "aws_lb_listener_certificate" "pages_wildcard" {
  for_each        = var.pages_wildcard_cert_ids
  listener_arn    = aws_lb_listener.cf_apps.arn
  certificate_arn = each.key
}

resource "aws_wafv2_web_acl_association" "cf_apps_waf_core" {
  resource_arn = aws_lb.cf_apps.arn
  web_acl_arn  = aws_wafv2_web_acl.cf_uaa_waf_core.arn
}

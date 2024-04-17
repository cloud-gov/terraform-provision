# These resources are for https://github.com/cloud-gov/external-domain-broker

/*
Domain Loadbalancer Groups
*/

resource "aws_lb" "domains_lbgroup" {
  count = var.domains_lbgroup_count

  name                       = "${var.stack_description}-domains-lbgroup-${count.index}"
  subnets                    = var.subnets
  security_groups            = var.security_groups
  ip_address_type            = "dualstack"
  idle_timeout               = 3600
  enable_deletion_protection = true
  access_logs {
    bucket  = var.elb_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_listener" "domains_lbgroup_http" {
  count = var.domains_lbgroup_count

  load_balancer_arn = aws_lb.domains_lbgroup[count.index].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.domains_lbgroup_apps_https[count.index].arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "domains_lbgroup_https" {
  count = var.domains_lbgroup_count

  load_balancer_arn = aws_lb.domains_lbgroup[count.index].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
  certificate_arn   = var.wildcard_arn

  default_action {
    target_group_arn = aws_lb_target_group.domains_lbgroup_apps_https[count.index].arn
    type             = "forward"
  }
}


## MAX 10 HOSTS
resource "aws_lb_listener_rule" "domains_lbgroup_logstash_listener_rule" {
  count = var.domains_lbgroup_count

  listener_arn = aws_lb_listener.domains_lbgroup_https[count.index].arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.domains_lbgroup_logstash_https[count.index].arn
  }

  condition {
    host_header {
      values = var.logstash_hosts
    }
  }
}

resource "aws_lb_target_group" "domains_lbgroup_apps_https" {
  count = var.domains_lbgroup_count

  name     = "${var.stack_description}-dlbg-apps-https-${count.index}"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 4
    interval            = 5
    port                = 81
    matcher             = 200
  }
}

resource "aws_lb_target_group" "domains_lbgroup_logstash_https" {
  count = var.domains_lbgroup_count

  name     = "${var.stack_description}-dlbg-logstash-${count.index}"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 4
    interval            = 5
    port                = 81
    matcher             = 200
  }
}

resource "aws_lb_target_group" "domains_lbgroup_gr_apps_https" {
  count = var.domains_lbgroup_count

  name     = "${var.stack_description}-dlbg-gr-apps-https-${count.index}"
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

resource "aws_lb_target_group" "domains_lbgroup_gr_logstash_https" {
  count = var.domains_lbgroup_count

  name     = "${var.stack_description}-dlbg-gr-logstash-${count.index}"
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

resource "aws_wafv2_web_acl_association" "domain_waf" {
  count = var.domains_lbgroup_count

  resource_arn = aws_lb.domains_lbgroup[count.index].arn
  web_acl_arn  = var.waf_arn
}

resource "aws_lb" "cf" {
  name            = "${var.stack_description}-cloudfoundry"
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

resource "aws_lb_target_group" "cf_gr_target_https" {
  name     = "${var.stack_description}-cf-gr-https"
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
  ssl_policy        = var.aws_lb_listener_ssl_policy
  certificate_arn   = var.elb_main_cert_id

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.cf_target_https.arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.cf_gr_target_https.arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }
}

resource "aws_lb_listener" "cf_http" {
  load_balancer_arn = aws_lb.cf.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.cf_target_https.arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.cf_gr_target_https.arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }
}

resource "aws_wafv2_web_acl_association" "cf_waf_core" {
  resource_arn = aws_lb.cf.arn
  web_acl_arn  = aws_wafv2_web_acl.cf_uaa_waf_core.arn
}

resource "aws_lb" "diego_api_bbs" {
  enable_cross_zone_load_balancing = false # example shows as true
  enable_deletion_protection       = false
  internal                         = true
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  name                             = "${var.stack_description}-diego-api-bbs-lb"
  security_groups                  = var.diego_api_bbs_nlb_security_groups

  subnet_mapping {
    private_ipv4_address = var.diego_api_bbs_private_ipv4_address_az1
    subnet_id            = var.private_subnet_az1
  }

  subnet_mapping {
    private_ipv4_address = var.diego_api_bbs_private_ipv4_address_az2
    subnet_id            = var.private_subnet_az2
  }

  #  tags = {
  #    Name = "${var.stack_description}-diego-api-bbs-lb"
  #  }
}


resource "aws_lb_target_group" "diego_api_bbs_tg" {
  name                              = "${var.stack_description}-diego-api-bbs"
  port                              = 8889 # Target port
  protocol                          = "TCP"
  target_type                       = "instance" # Can be instance, ip, or alb
  vpc_id                            = var.vpc_id
  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  preserve_client_ip                = "true"
  proxy_protocol_v2                 = "false"


  health_check {
    enabled             = true
    interval            = 6
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 5
    healthy_threshold   = 2 # 2 consecutive successes
    unhealthy_threshold = 2 # 2 consecutive failures
  }
}

resource "aws_lb_listener" "diego_api_bbs_listener" {
  load_balancer_arn = aws_lb.diego_api_bbs.arn
  port              = 8889
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.diego_api_bbs_tg.arn
  }
}



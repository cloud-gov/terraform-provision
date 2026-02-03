/* new dedicated load balancer group */
module "dedicated_loadbalancer_group" {
  source            = "../../modules/external_domain_broker_loadbalancer_group"
  stack_description = var.stack_description

  subnets                              = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  security_groups                      = [module.stack.web_traffic_security_group]
  elb_bucket_name                      = module.log_bucket.elb_bucket_name
  logstash_hosts                       = var.logstash_hosts
  vpc_id                               = module.stack.vpc_id
  domains_lbgroup_count                = var.domains_lbgroup_count
  wildcard_arn                         = data.aws_iam_server_certificate.wildcard.arn
  loadbalancer_forward_original_weight = var.loadbalancer_forward_original_weight
  loadbalancer_forward_new_weight      = var.loadbalancer_forward_new_weight
  aws_lb_listener_ssl_policy           = var.aws_lb_listener_ssl_policy
  notifications_arn                    = module.sns.cg_platform_slack_notifications_arn
}

resource "aws_lb" "domains_broker" {
  count = var.domains_broker_alb_count

  name                       = "${var.stack_description}-domains-${count.index}"
  subnets                    = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  security_groups            = [module.stack.web_traffic_security_group]
  ip_address_type            = "dualstack"
  idle_timeout               = 3600
  enable_deletion_protection = true
  access_logs {
    bucket  = module.log_bucket.elb_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_listener" "domains_broker_http" {
  count = var.domains_broker_alb_count

  load_balancer_arn = aws_lb.domains_broker[count.index].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.domains_broker_apps_https[count.index].arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.domains_broker_gr_apps_https[count.index].arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }
}

resource "aws_lb_listener" "domains_broker_https" {
  count = var.domains_broker_alb_count

  load_balancer_arn = aws_lb.domains_broker[count.index].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.aws_lb_listener_ssl_policy
  certificate_arn   = data.aws_iam_server_certificate.wildcard.arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.domains_broker_apps_https[count.index].arn
        weight = var.loadbalancer_forward_original_weight
      }
      target_group {
        arn    = aws_lb_target_group.domains_broker_gr_apps_https[count.index].arn
        weight = var.loadbalancer_forward_new_weight
      }
    }
  }
}

resource "aws_lb_target_group" "domains_broker_apps_https" {
  count = var.domains_broker_alb_count

  name     = "${var.stack_description}-domains-apps-https-${count.index}"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.stack.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 4
    interval            = 5
    port                = 81
    matcher             = 200
  }
}

resource "aws_lb_target_group" "domains_broker_gr_apps_https" {
  count = var.domains_broker_alb_count

  name     = "${var.stack_description}-domains-gapps-https${count.index}"
  port     = 10443
  protocol = "HTTPS"
  vpc_id   = module.stack.vpc_id

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
  count = var.domains_broker_alb_count

  resource_arn = aws_lb.domains_broker[count.index].arn
  web_acl_arn  = module.cf.cf_uaa_waf_core_arn
}

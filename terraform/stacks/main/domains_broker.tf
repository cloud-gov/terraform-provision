variable "domains_broker_alb_count" {
  default = 0
}

resource "aws_lb" "domains_broker" {
  count = "${var.domains_broker_alb_count}"

  name = "${var.stack_description}-domains-${count.index}"
  subnets = ["${module.stack.public_subnet_az1}", "${module.stack.public_subnet_az2}"]
  security_groups = ["${var.force_restricted_network == "no" ?
    module.stack.web_traffic_security_group :
    module.stack.restricted_web_traffic_security_group}"]
  ip_address_type = "dualstack"
}

resource "aws_lb_listener" "domains_broker_http" {
  count = "${var.domains_broker_alb_count}"

  load_balancer_arn = "${aws_lb.domains_broker.*.arn[count.index]}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.domains_broker_apps.*.arn[count.index]}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "domains_broker_https" {
  count = "${var.domains_broker_alb_count}"

  load_balancer_arn = "${aws_lb.domains_broker.*.arn[count.index]}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = "${var.main_cert_name != "" ?
    "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.main_cert_name}" :
    data.aws_iam_server_certificate.wildcard.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.domains_broker_apps.*.arn[count.index]}"
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "static" {
  count = "${var.domains_broker_alb_count}"

  listener_arn = "${aws_lb_listener.domains_broker_https.*.arn[count.index]}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.domains_broker_challenge.*.arn[count.index]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/.well-known/acme-challenge/*"]
  }
}

resource "aws_lb_target_group" "domains_broker_apps" {
  count = "${var.domains_broker_alb_count}"

  name = "${var.stack_description}-domains-apps-${count.index}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 4
    interval = 5
    port = 81
    matcher = 200
  }
}

resource "aws_lb_target_group" "domains_broker_challenge" {
  count = "${var.domains_broker_alb_count}"

  name = "${var.stack_description}-domains-acme-${count.index}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"
}

output "domains_broker_alb_names" {
  value = "aws_lb.domains_broker.*.name"
}

output "domains_broker_target_group_apps_names" {
  value = "aws_lb_target_group.domains_broker_apps.*.name"
}

output "domains_broker_target_group_challenge_names" {
  value = "aws_lb_target_group.domains_broker_challenge.*.name"
}

output "domains_broker_listener_arns" {
  value = "aws_lb_listener.domains_broker.*.arn"
}

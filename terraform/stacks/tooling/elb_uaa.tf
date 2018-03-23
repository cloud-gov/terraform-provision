resource "aws_elb" "bosh_uaa_elb" {
  name = "${var.stack_description}-bosh-uaa"
  subnets = ["${module.stack.public_subnet_az1}" ,"${module.stack.public_subnet_az2}"]
  security_groups = ["${module.stack.web_traffic_security_group}"]

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 8081
    instance_protocol = "HTTP"

    ssl_certificate_id = "${var.bosh_uaa_elb_cert_name != "" ?
      "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.bosh_uaa_elb_cert_name}" :
      data.aws_iam_server_certificate.wildcard_staging.arn}"
  }

  health_check {
    healthy_threshold = 2
    interval = 61
    target = "TCP:8081"
    timeout = 60
    unhealthy_threshold = 3
  }

  tags {
    Name = "${var.stack_description}-bosh-uaa"
  }
}

resource "aws_app_cookie_stickiness_policy" "opslogin_jsession_stickiness" {
  name = "${var.stack_description}-opslogin-sticky-jsession"
  load_balancer = "${aws_elb.bosh_uaa_elb.name}"
  lb_port = 443
  cookie_name = "JSESSIONID"
}

resource "aws_lb" "opsuaa" {
  name = "${var.stack_description}-opsuaa"
  subnets = ["${module.stack.public_subnet_az1}", "${module.stack.public_subnet_az2}"]
  security_groups = ["${module.stack.restricted_web_traffic_security_group}"]
  idle_timeout = 3600
}

resource "aws_lb_target_group" "opsuaa_target" {
  name     = "${var.stack_description}-opsuaa"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"

  health_check {
    healthy_threshold = 2
    interval = 61
    timeout = 60
    unhealthy_threshold = 3
    path = "/healthz"
    matcher = 200
  }
}

resource "aws_lb_listener" "opsuaa_listener" {
  load_balancer_arn = "${aws_lb.opsuaa.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = "${var.production_cert_name != "" ?
    "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.production_cert_name}" :
    data.aws_iam_server_certificate.wildcard_production.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.opsuaa_target.arn}"
    type             = "forward"
  }
}

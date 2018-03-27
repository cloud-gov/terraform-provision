resource "aws_elb" "cloudfoundry_elb_main" {
  name = "${var.stack_description}-CloudFoundry-Main"
  subnets = ["${var.elb_subnets}"]
  security_groups = ["${var.elb_security_groups}"]

  listener {
    lb_port = 80
    lb_protocol = "HTTP"
    instance_port = 80
    instance_protocol = "HTTP"
  }

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 80
    instance_protocol = "HTTP"

    ssl_certificate_id = "${var.elb_main_cert_id}"
  }

  health_check {
    healthy_threshold = 2
    interval = 5
    target = "HTTP:81/"
    timeout = 4
    unhealthy_threshold = 3
  }

  tags {
    Name = "${var.stack_description}-CloudFoundry-Main"
  }
}

resource "aws_lb_target_group" "cf_target" {
  name     = "${var.stack_description}-cf"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    interval = 5
    port = 81
    timeout = 4
    unhealthy_threshold = 3
    matcher = 200
  }
}

resource "aws_lb_listener_rule" "cf" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.listener_arn}"
  priority = "${1000 + count.index}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cf_target.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}

resource "aws_lb_listener_rule" "cf_http" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.http_listener_arn}"
  priority = "${1000 + count.index}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cf_target.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}

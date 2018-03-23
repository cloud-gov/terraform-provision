resource "aws_elb" "concourse_elb" {
  name = "${replace("${var.stack_description}-Concourse-${var.concourse_az}", "/(.{0,32})(.*)/", "$1")}"
  subnets = ["${var.elb_subnets}"]
  security_groups = ["${var.elb_security_groups}"]
  idle_timeout = 3600

  listener {
    instance_port = 8080
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "ssl"
    ssl_certificate_id = "${var.elb_cert_id}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "tcp:8080"
    interval = 30
  }

  tags {
    Name = "${var.stack_description}-Concourse-${var.concourse_az}"
  }
}

resource "aws_lb_target_group" "concourse_target" {
  name     = "${var.stack_description}-concourse-${var.concourse_az}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    interval = 30
    matcher = 200
  }
}

resource "aws_lb_listener_rule" "concourse_listener_rule" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.concourse_target.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}

resource "aws_elb" "prometheus_elb" {
  name = "${var.stack_description}-Prometheus"
  subnets = ["${var.elb_subnets}"]
  security_groups = ["${var.prometheus_elb_security_groups}"]
  idle_timeout = 3600

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 8080
    instance_protocol = "HTTP"
    ssl_certificate_id = "${var.elb_cert_id}"
  }

  health_check {
    healthy_threshold = 2
    interval = 5
    target = "HTTP:8080/ping"
    timeout = 4
    unhealthy_threshold = 3
  }

  tags {
    Name = "${var.stack_description}-Prometheus"
  }
}

resource "aws_lb_target_group" "prometheus_target" {
  name     = "${var.stack_description}-prometheus"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    interval = 5
    path = "/ping"
    timeout = 4
    unhealthy_threshold = 3
    matcher = 200
  }
}

resource "aws_lb_listener_rule" "prometheus_listener_rule" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.prometheus_target.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}

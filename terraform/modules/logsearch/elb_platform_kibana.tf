resource "aws_elb" "platform_kibana_elb" {
  name = "${var.stack_description}-platform-kibana"
  subnets = ["${var.public_elb_subnets}"]
  security_groups = ["${var.restricted_security_group}"]
  idle_timeout = 3600

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 5600
    instance_protocol = "http"
    ssl_certificate_id = "${var.elb_cert_id}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "TCP:5600"
    interval = 30
  }

  tags {
    Name = "${var.stack_description}-platform-kibana"
  }
}

resource "aws_lb_target_group" "platform_kibana" {
  name     = "${var.stack_description}-platform-kibana"
  port     = 5600
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    interval = 30
    matcher = 403
  }
}

resource "aws_lb_listener_rule" "platform_kibana" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.listener_arn}"
  priority = 200

  action {
    target_group_arn = "${aws_lb_target_group.platform_kibana.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}

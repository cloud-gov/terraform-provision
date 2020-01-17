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
    host_header {
      values = ["${element(var.hosts, count.index)}"]
    }
  }
}

resource "aws_lb_target_group" "nessus_target" {
  name     = "${var.stack_description}-nessus"
  port     = 8834
  protocol = "HTTPS"
  vpc_id   = "${module.stack.vpc_id}"

  health_check {
    protocol = "HTTPS"
    healthy_threshold = 2
    interval = 61
    timeout = 60
    unhealthy_threshold = 3
    matcher = 200
  }
}

resource "aws_lb_listener_rule" "nessus_listener_rule" {
  listener_arn = "${aws_lb_listener.main.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nessus_target.arn}"
  }

  condition {
    host_header {
      values = ["${var.nessus_hosts}"]
    }
  }
}

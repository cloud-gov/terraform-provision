resource "aws_lb_target_group" "shibboleth" {
  name     = "${var.stack_description}-shibboleth"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    interval = 15
    path = "/shibboleth"
    timeout = 10
    unhealthy_threshold = 2
    matcher = 200
  }

  stickiness {
    type = "lb_cookie"
    enabled = true
  }
}

resource "aws_lb_listener_rule" "shibboleth" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.listener_arn}"
  priority = "${100 + count.index}"

  action {
    target_group_arn = "${aws_lb_target_group.shibboleth.arn}"
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${element(var.hosts, count.index)}"]
    }
  }
}

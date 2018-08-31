resource "aws_lb_target_group" "admin" {
  name     = "${var.stack_description}-admin"
  port     = 8070
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    interval = 15
    path = "/"
    timeout = 15
    unhealthy_threshold = 2
    matcher = 200
  }
}

resource "aws_lb_listener_rule" "admin" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.listener_arn}"
  priority = "${100 + count.index}"

  action {
    target_group_arn = "${aws_lb_target_group.admin.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}

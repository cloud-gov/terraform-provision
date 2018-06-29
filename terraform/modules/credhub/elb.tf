resource "aws_lb_target_group" "credhub_target" {
  name     = "${var.stack_description}-credhub-${var.credhub_az}"
  port     = 8844
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

resource "aws_lb_listener_rule" "credhub" {
  count = "${length(var.hosts)}"

  listener_arn = "${var.listener_arn}"

  action {
    target_group_arn = "${aws_lb_target_group.credhub.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${element(var.hosts, count.index)}"]
  }
}

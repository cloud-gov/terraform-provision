resource "aws_lb_target_group" "concourse_target" {
  name     = "${var.stack_description}-concourse-target"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = 200
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
}

resource "aws_lb_listener_rule" "concourse_listener_rule" {
  count = length(var.hosts)

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.concourse_target.arn
  }

  condition {
    host_header {
      values = [element(var.hosts, count.index)]
    }
  }
}


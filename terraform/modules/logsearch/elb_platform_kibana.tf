resource "aws_lb_target_group" "platform_kibana" {
  name     = "${var.stack_description}-platform-kibana"
  port     = 5600
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = 403
  }
}

resource "aws_lb_listener_rule" "platform_kibana" {
  count = length(var.hosts)

  listener_arn = var.listener_arn
  priority     = 200 + count.index

  action {
    target_group_arn = aws_lb_target_group.platform_kibana.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [element(var.hosts, count.index)]
    }
  }
}

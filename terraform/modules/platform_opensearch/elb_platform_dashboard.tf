resource "aws_lb_target_group" "platform_dashboard" {
  name     = "${var.stack_description}-platform-dashboard"
  port     = 5605
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = 403
  }
}

resource "aws_lb_listener_rule" "platform_dashboard" {
  count        = length(var.hosts)
  
  listener_arn = var.listener_arn
  priority     = 203 + count.index
  
  action {
    target_group_arn = aws_lb_target_group.platform_dashboard.arn
    type             = "forward"
  }
  condition {
    host_header {
      values = [element(var.hosts, count.index)]
    }
  }
  
}
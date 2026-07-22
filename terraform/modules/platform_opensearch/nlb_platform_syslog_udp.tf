resource "aws_lb" "platform_syslog_udp_nlb" {
  name               = "${var.stack_description}-plat-syslog-udp"
  load_balancer_type = "network"
  subnets            = var.private_elb_subnets
  internal           = true

  tags = {
    Name = "${var.stack_description}-platform-syslog-udp"
  }
}

resource "aws_lb_target_group" "platform_syslog_udp" {
  name     = "${var.stack_description}-plat-syslog-udp"
  port     = 5431
  protocol = "UDP"
  vpc_id   = var.vpc_id

  # UDP target groups can't health check on UDP; use a TCP health check.
  health_check {
    protocol            = "TCP"
    port                = 5431
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_listener" "platform_syslog_udp" {
  load_balancer_arn = aws_lb.platform_syslog_udp_nlb.arn
  protocol          = "UDP"
  port              = 5431

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.platform_syslog_udp.arn
  }
}

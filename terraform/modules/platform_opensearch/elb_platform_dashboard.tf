resource "aws_lb_target_group" "platform_dashboard" {
  name     = "${var.stack_description}-platform-dashboard"
  port     = 5605
  protocol = "TLS"
  vpc_id   = var.vpc_id
}

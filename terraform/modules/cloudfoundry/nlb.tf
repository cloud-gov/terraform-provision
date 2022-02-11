resource "aws_lb" "cf_apps_tcp" {
  count = var.tcp_lb_count
  name            = "${var.stack_description}-cf-tcp-${count.index}"
  subnets         = var.elb_subnets
  security_groups = var.elb_security_groups
  ip_address_type = "dualstack"
  idle_timeout    = 3600
  access_logs {
    bucket  = var.log_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_target_group" "cf_apps_target_tcp" {
  count = var.tcp_lb_count
  name     = "${var.stack_description}-cf-tcp-${count.index}"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

}

resource "aws_lb_listener" "cf_apps_tcp" {
  count = var.tcp_lb_count
  load_balancer_arn = aws_lb.cf_apps_tcp[count.index].arn
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.cf_apps_target_tcp[count.index].arn
    type             = "forward"
  }
}
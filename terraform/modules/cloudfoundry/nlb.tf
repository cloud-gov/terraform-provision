resource "aws_lb" "cf_apps_tcp" {
  count              = var.tcp_lb_count
  name               = "${var.stack_description}-cf-tcp-${count.index}"
  load_balancer_type = "network"
  subnets            = var.elb_subnets
  ip_address_type    = "dualstack"
}

resource "aws_lb_target_group" "cf_apps_target_tcp" {
  count    = var.tcp_lb_count
  name     = "${var.stack_description}-cf-tcp-${count.index}"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

}

resource "aws_lb_listener" "cf_apps_tcp" {
  count             = var.tcp_lb_count * var.listeners_per_tcp_lb
  load_balancer_arn = aws_lb.cf_apps_tcp[floor(count.index/var.listeners_per_tcp_lb)].arn
  protocol          = "TCP"
  port              = var.tcp_first_port + count.index


  default_action {
    target_group_arn = aws_lb_target_group.cf_apps_target_tcp[floor(count.index/var.listeners_per_tcp_lb)].arn
    type             = "forward"
  }
}
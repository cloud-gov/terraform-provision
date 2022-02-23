resource "aws_security_group" "nlb_traffic" {
  description = "Allow traffic in to NLB"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = var.tcp_first_port
    to_port          = var.tcp_lb_count * var.listeners_per_tcp_lb + var.tcp_first_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.stack_description} - Incoming TCP Traffic"
  }
}

resource "aws_lb" "cf_apps_tcp" {
  count              = var.tcp_lb_count
  name               = "${var.stack_description}-cf-tcp-${count.index}"
  load_balancer_type = "network"
  subnets            = var.elb_subnets
  ip_address_type    = "dualstack"
  security_groups    = [aws_security_group.nlb_traffic.id]
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
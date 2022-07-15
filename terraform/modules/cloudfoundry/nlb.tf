locals {
  additional_tcp_targets = var.tcp_lb_count * length(var.tcp_additional_ports)
}

resource "aws_security_group" "nlb_traffic" {
  count       = var.tcp_lb_count > 0 ? 1 : 0
  description = "Allow traffic in to NLB"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = var.tcp_first_port
    to_port          = var.tcp_lb_count * var.listeners_per_tcp_lb + var.tcp_first_port
    protocol         = "tcp"
    cidr_blocks      = var.tcp_allow_cidrs_ipv4
    ipv6_cidr_blocks = var.tcp_allow_cidrs_ipv6
  }

  dynamic "ingress" {
    for_each = var.tcp_additional_ports
    content {
      from_port        = setting.value
      to_port          = setting.value
      protocol         = "tcp"
      cidr_blocks      = var.tcp_allow_cidrs_ipv4
      ipv6_cidr_blocks = var.tcp_allow_cidrs_ipv6
    }
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
}

resource "aws_lb_target_group" "cf_apps_target_tcp" {
  count    = var.tcp_lb_count * var.listeners_per_tcp_lb
  name     = "${var.stack_description}-cf-tcp-${count.index}"
  port     = var.tcp_first_port + count.index
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "cf_apps_target_tcp_additional" {
  count    = local.additional_tcp_targets
  name     = "${var.stack_description}-cf-tcp-additional-${count.index}"
  port     = var.tcp_additional_ports[floor(count.index / local.additional_tcp_targets)]
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "cf_apps_tcp" {
  count             = var.tcp_lb_count * var.listeners_per_tcp_lb
  load_balancer_arn = aws_lb.cf_apps_tcp[floor(count.index / var.listeners_per_tcp_lb)].arn
  protocol          = "TCP"
  port              = var.tcp_first_port + count.index

  default_action {
    target_group_arn = aws_lb_target_group.cf_apps_target_tcp[count.index].arn
    type             = "forward"
  }
}

# resource "aws_lb_listener" "cf_apps_tcp_additional" {
#   count             = var.tcp_lb_count
#   load_balancer_arn = aws_lb.cf_apps_tcp[count.index].arn
#   protocol          = "TCP"
#   port              = 443

#   default_action {
#     target_group_arn = aws_lb_target_group.cf_apps_target_tcp_443[count.index].arn
#     type             = "forward"
#   }
# }

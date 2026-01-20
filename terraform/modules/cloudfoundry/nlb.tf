resource "aws_security_group" "nlb_traffic" {
  count       = var.tcp_lb_count > 0 ? 1 : 0
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
  count                      = var.tcp_lb_count
  name                       = "${var.stack_description}-cf-tcp-${count.index}"
  load_balancer_type         = "network"
  subnets                    = var.elb_subnets
  ip_address_type            = "dualstack"
  enable_deletion_protection = true
}

resource "aws_lb_target_group" "cf_apps_target_tcp" {
  count    = var.tcp_lb_count * var.listeners_per_tcp_lb
  name     = "${var.stack_description}-cf-tcp-${count.index}"
  port     = var.tcp_first_port + count.index
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


resource "aws_lb" "diego_api_bbs" {
  enable_cross_zone_load_balancing = false # we already load balance these target vms across azs at the BOSH level
  enable_deletion_protection       = false
  internal                         = true
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  name                             = "${var.stack_description}-diego-api-bbs-lb"
  security_groups                  = var.diego_api_bbs_nlb_security_groups

  subnet_mapping {
    private_ipv4_address = var.diego_api_bbs_private_ipv4_address_az1
    subnet_id            = var.private_subnet_az1
  }

  subnet_mapping {
    private_ipv4_address = var.diego_api_bbs_private_ipv4_address_az2
    subnet_id            = var.private_subnet_az2
  }

  tags = {
    Name = "${var.stack_description}-diego-api-bbs-lb"
  }
}


resource "aws_lb_target_group" "diego_api_bbs_tg" {
  name                              = "${var.stack_description}-diego-api-bbs"
  port                              = 8889
  protocol                          = "TCP"
  target_type                       = "instance" # Can be instance, ip, or alb
  vpc_id                            = var.vpc_id
  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  preserve_client_ip                = "true"
  proxy_protocol_v2                 = "false"


  health_check {
    enabled             = true
    interval            = 6
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 5
    healthy_threshold   = 2 # 2 consecutive successes
    unhealthy_threshold = 2 # 2 consecutive failures
  }
}

resource "aws_lb_listener" "diego_api_bbs_listener" {
  load_balancer_arn = aws_lb.diego_api_bbs.arn
  port              = 8889
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.diego_api_bbs_tg.arn
  }
}

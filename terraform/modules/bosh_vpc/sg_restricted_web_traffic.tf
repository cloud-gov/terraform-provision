/*
 * Variables required:
 *  stack_description
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_security_group" "restricted_web_traffic" {
  description = "Restricted web type traffic"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} - Restricted Incoming Web Traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_ipv4_ingress_rules" {
  for_each          = toset(var.restricted_ingress_web_cidrs)
  security_group_id = aws_security_group.restricted_web_traffic.id
  cidr_ipv4         = each.key
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "http_ipv6_ingress_rules" {
  for_each          = toset(var.restricted_ingress_web_ipv6_cidrs)
  security_group_id = aws_security_group.restricted_web_traffic.id
  cidr_ipv6         = each.key
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https_ipv4_ingress_rules" {
  for_each          = toset(var.restricted_ingress_web_cidrs)
  security_group_id = aws_security_group.restricted_web_traffic.id
  cidr_ipv4         = each.key
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https_ipv6_ingress_rules" {
  for_each          = toset(var.restricted_ingress_web_ipv6_cidrs)
  security_group_id = aws_security_group.restricted_web_traffic.id
  cidr_ipv6         = each.key
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_egress_ipv4" {
  security_group_id = aws_security_group.restricted_web_traffic.id
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all_egress_ipv6" {
  security_group_id = aws_security_group.restricted_web_traffic.id
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"
}

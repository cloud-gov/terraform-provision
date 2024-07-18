resource "aws_security_group_rule" "bosh_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "dns_tcp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "dns_udp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "ntp_udp" {
  type              = "ingress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "bosh_nats" {
  type              = "ingress"
  from_port         = 4222
  to_port           = 4222
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "bosh_agent" {
  type              = "ingress"
  from_port         = 6868
  to_port           = 6868
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "uaa_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "uaa_https" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "credhub_https" {
  type              = "ingress"
  from_port         = 8844
  to_port           = 8844
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "bosh_director" {
  type              = "ingress"
  from_port         = 25555
  to_port           = 25555
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}

resource "aws_security_group_rule" "bosh_registry" {
  type              = "ingress"
  from_port         = 25777
  to_port           = 25777
  protocol          = "tcp"
  cidr_blocks       = [var.source_vpc_cidr]
  security_group_id = var.target_bosh_security_group
}


/*
 * Variables required:
 *  stack_description
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc' is the vpc for this
 *   bosh environment (the director and the vms it manages)
 */


# this security group is applied to all the vms in this stack, including the bosh director
resource "aws_security_group" "bosh" {
  description = "BOSH security group"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} - BOSH"
  }
}


resource "aws_security_group_rule" "self_reference" {
  type              = "ingress"
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "bosh_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "dns_tcp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "dns_udp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}
resource "aws_security_group_rule" "ntp_udp" {
  type              = "ingress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "http_elb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 81
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "https_elb" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "http_alt_elb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "cf_ssh" {
  type              = "ingress"
  from_port         = 4222
  to_port           = 4222
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "diego_ssh" {
  type              = "ingress"
  from_port         = 2222
  to_port           = 2222
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "bosh_nats" {
  type              = "ingress"
  from_port         = 6868
  to_port           = 6868
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "bosh_director" {
  type              = "ingress"
  from_port         = 25555
  to_port           = 25555
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "node_exporter" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  cidr_blocks              = var.monitoring_security_group_cidrs
  security_group_id        = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "platform_kibana" {
  type              = "ingress"
  from_port         = 5600
  to_port           = 5600
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main_vpc.cidr_block]
  security_group_id = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "monitoring_elasticsearch_exporter" {
  type                     = "ingress"
  from_port                = 9114
  to_port                  = 9114
  protocol                 = "tcp"
  cidr_blocks              = var.monitoring_security_group_cidrs
  security_group_id        = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "concourse_logsearch" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  cidr_blocks              = var.concourse_security_group_cidrs
  security_group_id        = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "concourse_secureproxy" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = var.concourse_security_group_cidrs
  security_group_id        = aws_security_group.bosh.id
}

resource "aws_security_group_rule" "concourse_secureproxy_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = var.concourse_security_group_cidrs
  security_group_id        = aws_security_group.bosh.id
}


resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bosh.id
}

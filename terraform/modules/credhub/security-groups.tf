/*
 * Variables required:
 *  stack_description
 *  vpc_id
 */

resource "aws_security_group" "credhub" {
  name = "${var.stack_description}-allow-incoming-credhub"
  description = "Allow access to incoming credhub traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.stack_description} - Incoming Credhub Traffic"
  }
}

resource "aws_security_group_rule" "self_reference" {
  type              = "ingress"
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.credhub.id
}

resource "aws_security_group_rule" "credhub" {
  type              = "ingress"
  from_port         = 8844
  to_port           = 8845
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.credhub.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.credhub.id
}


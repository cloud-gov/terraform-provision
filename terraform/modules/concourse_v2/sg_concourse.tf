/*
 * Variables required:
 *  stack_description
 *  vpc_id
 */

resource "aws_security_group" "concourse" {
  description = "Allow access to incoming concourse traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.stack_description} - Incoming Concourse Traffic"
  }
}

resource "aws_security_group_rule" "self_reference" {
  type              = "ingress"
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.concourse.id
}

resource "aws_security_group_rule" "concourse_web" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.concourse.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.concourse.id
}


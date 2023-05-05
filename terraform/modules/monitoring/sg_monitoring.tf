/*
 * Variables required:
 *  stack_description
 *  vpc_id
 */

resource "aws_security_group" "monitoring" {
  name = "${var.stack_description}-incoming-monitoring"
  description = "Allow access to incoming monitoring traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.stack_description} - Incoming Monitoring Traffic"
  }
}

resource "aws_security_group_rule" "self_reference" {
  type              = "ingress"
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "monitoring_nginx" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "all"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monitoring.id
}


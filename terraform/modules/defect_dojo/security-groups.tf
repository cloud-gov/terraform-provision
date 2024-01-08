resource "aws_security_group" "defectdojo" {
  description = "Allow access to incoming defect dojo traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.stack_description} - Incoming Defect Dojo Traffic"
  }
}

resource "aws_security_group_rule" "self_reference" {
  type              = "ingress"
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.defectdojo.id
}

resource "aws_security_group_rule" "defectdojo_web" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.defectdojo.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.defectdojo.id
}

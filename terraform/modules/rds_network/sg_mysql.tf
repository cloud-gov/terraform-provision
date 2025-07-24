/*
 * Variables required:
 *   stack_description
 *   vpc_id
 */

resource "aws_security_group" "rds_mysql" {
  description = "Allow access to incoming mysql traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.security_groups
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = var.security_groups
  }

  tags = {
    Name = "${var.stack_description} - Incoming MySQL Traffic"
  }

}
resource "aws_security_group_rule" "ingress_tooling" {

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidrs
  security_group_id = aws_security_group.rds_postgres.id
}
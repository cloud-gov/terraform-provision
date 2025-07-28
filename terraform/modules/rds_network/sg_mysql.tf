/*
 * Variables required:
 *   stack_description
 *   vpc_id
 */

resource "aws_security_group" "rds_mysql" {
  description = "Allow access to incoming mysql traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.stack_description} - Incoming MySQL Traffic"
  }
}

resource "aws_security_group_rule" "mysql_ingress_default" {
  count = var.security_groups_count

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.rds_mysql.id
}

resource "aws_security_group_rule" "mysql_egress_default" {
  count = var.security_groups_count

  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.rds_mysql.id
}

resource "aws_security_group_rule" "mysql_ingress_tooling" {

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidrs
  security_group_id = aws_security_group.rds_mysql.id
}
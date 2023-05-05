/*
 * Variables required:
 *   stack_description
 *   vpc_id
 */

data "aws_region" "current" {}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_security_group" "rds_postgres" {
  name = "${var.stack_description}-incoming-db-postgresql"
  description = "Allow access to incoming postgresql traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.stack_description} - Incoming PostGreSQL Traffic"
  }
}

resource "aws_security_group_rule" "ingress_default" {
  count = var.security_groups_count

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.rds_postgres.id
}

resource "aws_security_group_rule" "egress_default" {
  count = var.security_groups_count

  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.rds_postgres.id
}

# allows pg rds to get to s3 for import and export
resource "aws_security_group_rule" "egress_s3" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_prefix_list.s3.id]
  security_group_id = aws_security_group.rds_postgres.id
}

resource "aws_security_group_rule" "ingress_tooling" {

  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidrs
  security_group_id = aws_security_group.rds_postgres.id
}

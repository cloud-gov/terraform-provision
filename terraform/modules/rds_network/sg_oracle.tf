/*
 * Variables required:
 *   stack_description
 *   vpc_id
 *   security_groups        (list of source SG IDs allowed to reach Oracle)
 *   security_groups_count  (length of security_groups)
 */

resource "aws_security_group" "rds_oracle" {
  description = "Allow access to incoming Oracle traffic"
  vpc_id      = var.vpc_id

  # Declare empty inline rule sets so Terraform actively removes any rules that
  # were previously managed inline on this SG (notably the legacy plaintext 1521
  # ingress). Without this, migrating from inline blocks to the standalone
  # aws_security_group_rule resources below only ADDS the new rules and leaves the
  # old inline ones orphaned on the live SG. All actual rules are managed as the
  # standalone resources below (TCPS 2484 + egress only).
  ingress = []
  egress  = []

  tags = {
    Name = "${var.stack_description} - Incoming Oracle Traffic"
  }
}

resource "aws_security_group_rule" "oracle_ingress_tcps" {
  count = var.security_groups_count

  description              = "Oracle TCPS/TLS listener (2484) from allowed source SGs"
  type                     = "ingress"
  from_port                = 2484
  to_port                  = 2484
  protocol                 = "tcp"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.rds_oracle.id
}

resource "aws_security_group_rule" "oracle_egress_default" {
  count = var.security_groups_count

  description              = "Oracle egress to allowed source SGs"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.rds_oracle.id
}

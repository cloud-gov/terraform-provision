/*
 * Variables required:
 *   stack_description
 *   vpc_id
 *   security_groups        (list of source SG IDs allowed to reach Oracle)
 *   security_groups_count  (length of security_groups)
 *   oracle_rules_enabled   (false in stacks with no Oracle RDS, e.g. tooling)
 */

locals {
  # Rule count per source SG, gated by oracle_rules_enabled so stacks without an
  # Oracle RDS (tooling) create no Oracle rules at all.
  oracle_rules_count = var.oracle_rules_enabled ? tonumber(var.security_groups_count) : 0
}

resource "aws_security_group" "rds_oracle" {
  description = "Allow access to incoming Oracle traffic"
  vpc_id      = var.vpc_id

  # Rules are managed exclusively by the standalone aws_security_group_rule
  # resources below (matching sg_postgres.tf / sg_mysql.tf). Do NOT declare
  # inline ingress/egress here — not even `= []`: an explicit empty inline set
  # means "Terraform manages the inline rules and they must be empty", which
  # fights the standalone rules and makes every apply oscillate (the SG resource
  # deletes the standalone 2484 rule, the standalone resource re-creates it, …).
  # Omitting them entirely leaves inline rules unmanaged so the standalone
  # resources are the single source of truth.

  tags = {
    Name = "${var.stack_description} - Incoming Oracle Traffic"
  }
}

resource "aws_security_group_rule" "oracle_ingress_tcps" {
  count = local.oracle_rules_count

  description              = "Oracle TCPS/TLS listener (2484) from allowed source SGs"
  type                     = "ingress"
  from_port                = 2484
  to_port                  = 2484
  protocol                 = "tcp"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.rds_oracle.id
}

resource "aws_security_group_rule" "oracle_egress_default" {
  count = local.oracle_rules_count

  description              = "Oracle egress to allowed source SGs"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.rds_oracle.id
}

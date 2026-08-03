/*
 * Variables required:
 *   stack_description
 *   vpc_id
 */

resource "aws_security_group" "rds_oracle" {
  description = "Allow access to incoming Oracle traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 1521
    to_port         = 1521
    protocol        = "tcp"
    security_groups = var.security_groups
  }

  # TCPS listener for encryption-in-transit (SC-8 / SC-8(1) / SC-13). RDS Oracle
  # serves TLS on a separate port (2484), provisioned by the broker's SSL option
  # group; this rule opens ingress to it. The plaintext 1521 rule above is
  # intentionally retained for now (non-breaking); removing it to enforce
  # TLS-only is a follow-up once all consumers use 2484.
  ingress {
    from_port       = 2484
    to_port         = 2484
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
    Name = "${var.stack_description} - Incoming Oracle Traffic"
  }
}

/*
 * Variables required:
 *   stack_description
 *   vpc_id
 */

resource "aws_security_group" "rds_oracle" {
  name        = "${var.stack_description}-incoming-db-oracle"
  description = "Allow access to incoming Oracle traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 1521
    to_port         = 1521
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


/*
 * Variables required:
 *   stack_description
 *   vpc_id
 */

resource "aws_security_group" "rds_mssql" {
  description = "Allow access to incoming mssql traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 1433
    to_port = 1433
    protocol = "tcp"
    security_groups = ["${var.security_groups}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${var.security_groups}"]
  }

  tags {
    Name = "${var.stack_description} - Incoming SQL Server Traffic"
  }
}

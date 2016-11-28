/*
 * Variables required:
 *   stack_description
 *   vpc_id
 */

resource "aws_security_group" "rds_postgres" {
  description = "Allow access to incoming postgresql traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = ["${var.bosh_security_group}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${var.bosh_security_group}"]
  }

  tags = {
    Name = "${var.stack_description} - Incoming PostGreSQL Traffic"
  }
}

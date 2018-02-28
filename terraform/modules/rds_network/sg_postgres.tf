/*
 * Variables required:
 *   stack_description
 *   vpc_id
 */

resource "aws_security_group" "rds_postgres" {
  description = "Allow access to incoming postgresql traffic"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.stack_description} - Incoming PostGreSQL Traffic"
  }
}

resource "aws_security_group_rule" "ingress_default" {
  count = "${length(var.security_groups)}"

  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  source_security_group_id = "${element(var.security_groups, count.index)}"
  security_group_id = "${aws_security_group.rds_postgres.id}"
}

resource "aws_security_group_rule" "egress_default" {
  count = "${length(var.security_groups)}"

  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${element(var.security_groups, count.index)}"
  security_group_id = "${aws_security_group.rds_postgres.id}"
}

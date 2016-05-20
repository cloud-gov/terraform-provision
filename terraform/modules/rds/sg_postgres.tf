/*
 * Variables required:
 *   vpc_id
 */

resource "aws_security_group" "rds_postgres" {
  description = "Allow access to incoming postgresql traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "rds_postgres_sg_id" {
  value = "${aws_security_group.rds_postgres.id}"
}
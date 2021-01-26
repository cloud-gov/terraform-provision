resource "aws_security_group" "elasticache_redis" {
  description = "Allow access to incoming redis traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    security_groups = ["${var.security_groups}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${var.security_groups}"]
  }

  tags = {
    Name = "${var.stack_description} - Incoming Redis Traffic"
  }
}

resource "aws_security_group" "dns" {
  description = "Allow access to incoming DNS traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    self = true
    from_port = 53
    to_port = 53
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.stack_description} - Incoming DNS Traffic"
  }
}

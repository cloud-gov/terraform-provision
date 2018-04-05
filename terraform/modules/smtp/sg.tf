resource "aws_security_group" "smtp_inbound" {
  description = "Allow access to smtp service from all our internal hosts"
  vpc_id = "${var.vpc_id}"

  ingress {
    self = true
    from_port = 25
    to_port = 25
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 587
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.stack_description} - smtp inbound"
  }
}

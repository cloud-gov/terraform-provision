resource "aws_security_group" "bosh_uaa_traffic" {
  description = "Allow access to incoming BOSH UAA traffic for operations"
  vpc_id      = module.stack.vpc_id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stack_description} - Incoming BOSH UAA Traffic for operations"
  }
}

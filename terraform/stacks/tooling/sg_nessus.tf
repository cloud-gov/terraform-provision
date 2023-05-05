/*
 * Variables required:
 *  stack_description
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_security_group" "nessus_traffic" {
  name = "${var.stack_description}-incoming-nessus"
  description = "Allow access to incoming nessus traffic"
  vpc_id      = module.stack.vpc_id

  ingress {
    from_port   = 8834
    to_port     = 8834
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
    Name = "${var.stack_description} - Incoming Nessus Traffic"
  }
}


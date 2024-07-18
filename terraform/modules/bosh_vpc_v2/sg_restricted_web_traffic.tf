/*
 * Variables required:
 *  stack_description
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_security_group" "restricted_web_traffic" {
  description = "Restricted web type traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.restricted_ingress_web_cidrs
    ipv6_cidr_blocks = var.restricted_ingress_web_ipv6_cidrs
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.restricted_ingress_web_cidrs
    ipv6_cidr_blocks = var.restricted_ingress_web_ipv6_cidrs
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.stack_description} - Restricted Incoming Web Traffic"
  }
}

/*
 * Variables required:
 *  stack_description
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_security_group" "nessus_traffic" {
  description = "Allow access to incoming nessus traffic"
  vpc_id = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port = 8834
    to_port = 8834
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Name = "${var.stack_description} - Incoming Nessus Traffic"
  }

}

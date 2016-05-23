/*
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_security_group" "local_vpc_traffic" {
  description = "Enable access to all VPC CIDR block ips"
  vpc_id = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  tags =  {
    Name = "${var.stack_description} - Local Traffic ${aws_vpc.main_vpc.cidr_block}"
  }
}


output "local_vpc_traffic_sg_id" {
    value = "${aws_security_group.local_vpc_traffic.id}"
}

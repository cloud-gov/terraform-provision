/*
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_security_group" "bosh" {
  description = "BOSH security group"
  vpc_id = "${aws_vpc.main_vpc.id}"

  ingress {
    self = true
    from_port = 0
    to_port = 0
    protocol = -1
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  ingress {
    from_port = 4222
    to_port = 4222
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  ingress {
    from_port = 6868
    to_port = 6868
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  ingress {
    from_port = 25555
    to_port = 25555
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

}

output "bosh_sg_id" {
  value = "${aws_security_group.bosh.id}"
}
variable "az1" {}

variable "ingress_cidrs" {
  type = "list"
  default = ["159.142.0.0/16"]
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.az1}"
}

resource "aws_security_group" "bootstrap" {
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.ingress_cidrs}"]
  }

  ingress {
    from_port = 4443
    to_port = 4443
    protocol = "tcp"
    cidr_blocks = ["${var.ingress_cidrs}"]
  }

  ingress {
    from_port = 6868
    to_port = 6868
    protocol = "tcp"
    cidr_blocks = ["${var.ingress_cidrs}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "bootstrap" {
  vpc = true
}

output "public_subnet_id" {
  value = "${aws_default_subnet.default_az1.id}"
}

output "public_subnet_cidr" {
  value = "${aws_default_subnet.default_az1.cidr_block}"
}

output "public_subnet_gateway" {
  value = "${cidrhost("${aws_default_subnet.default_az1.cidr_block}", 1)}"
}

output "private_ip" {
  value = "${cidrhost("${aws_default_subnet.default_az1.cidr_block}", 100)}"
}

output "public_ip" {
  value = "${aws_eip.bootstrap.public_ip}"
}

output "security_group_id" {
  value = "${aws_security_group.bootstrap.id}"
}

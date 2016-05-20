/*
 * Variables required:
 *  stack_description
 *  vpc_cidr
 */

resource "aws_vpc" "main_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags =  {
    Name = "${var.stack_description}"
  }

}

output "vpc_id" {
    value = "${aws_vpc.main_vpc.id}"
}

output "vpc_cidr" {
    value = "${var.vpc_cidr}"
}
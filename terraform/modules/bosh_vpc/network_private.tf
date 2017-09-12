/*
 * Variables required:
 *  stack_description
 *  az1
 *  az2
 *  private_cidr_1
 *  private_cidr_2
 *  nat_gateway_instance_type
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_subnet" "az1_private" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.private_cidr_1}"
  availability_zone = "${var.az1}"

  tags {
    Name = "${var.stack_description} (Private AZ1)"
  }
}

resource "aws_subnet" "az2_private" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.private_cidr_2}"
  availability_zone = "${var.az2}"

  tags {
    Name = "${var.stack_description} (Private AZ2)"
  }
}

resource "aws_route_table" "az1_private_route_table" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name = "${var.stack_description} (Private Route Table)"
  }
}

resource "aws_route_table" "az2_private_route_table" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name = "${var.stack_description} (Private Route Table)"
  }
}

resource "aws_route_table_association" "az1_private_rta" {
  subnet_id = "${aws_subnet.az1_private.id}"
  route_table_id = "${aws_route_table.az1_private_route_table.id}"
}

resource "aws_route_table_association" "az2_private_rta" {
  subnet_id = "${aws_subnet.az2_private.id}"
  route_table_id = "${aws_route_table.az2_private_route_table.id}"
}

/*
 * For rotation purposes, create new NAT instance below first,
 * then update the routes and EIP references after they
 * have been created
 */
resource "aws_route" "az1_nat_route" {
    route_table_id = "${aws_route_table.az1_private_route_table.id}"
    destination_cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.az1_private_nat_2017_09.id}"
}
resource "aws_route" "az2_nat_route" {
    route_table_id = "${aws_route_table.az2_private_route_table.id}"
    destination_cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.az2_private_nat_2017_09.id}"
}

resource "aws_eip" "az1_nat_eip" {
  instance = "${aws_instance.az1_private_nat_2017_09.id}"
  vpc = true

  count = "${var.use_nat_gateway_eip == "true" ? 1 : 0}"

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_eip" "az2_nat_eip" {
  instance = "${aws_instance.az2_private_nat_2017_09.id}"
  vpc = true

  count = "${var.use_nat_gateway_eip == "true" ? 1 : 0}"

  lifecycle {
    prevent_destroy = true
  }
}

/*
 * For NAT gateway instances:
 * Lookup latest in table for NAT instance in GovCloud
 * and name them to correspond with the AMI release date
 * until native NAT Gateway instances are available
 * https://aws.amazon.com/amazon-linux-ami/
 */
resource "aws_instance" "az1_private_nat_2017_03" {
  ami = "ami-6ae2660b"
  instance_type = "t2.micro"
  source_dest_check = false

  # this always needs to be true, if use_nat_gateway_eip is set, the ephemeral address will not be used
  # see https://github.com/hashicorp/terraform/issues/9811 for more detail than you want
  associate_public_ip_address = true

  subnet_id = "${aws_subnet.az1_public.id}"

  vpc_security_group_ids = ["${aws_security_group.local_vpc_traffic.id}"]

  tags {
    Name = "${var.stack_description} (AZ1 2017-03 NAT)"
  }
}
resource "aws_instance" "az2_private_nat_2017_03" {
  ami = "ami-6ae2660b"
  instance_type = "t2.micro"
  source_dest_check = false

  # this always needs to be true, if use_nat_gateway_eip is set, the ephemeral address will not be used
  # see https://github.com/hashicorp/terraform/issues/9811 for more detail than you want
  associate_public_ip_address = true

  subnet_id = "${aws_subnet.az2_public.id}"

  vpc_security_group_ids = ["${aws_security_group.local_vpc_traffic.id}"]

  tags {
    Name = "${var.stack_description}  (AZ2 2017-03 NAT)"
  }
}

resource "aws_instance" "az1_private_nat_2017_09" {
  ami = "ami-4b98182a"
  instance_type = "${var.nat_gateway_instance_type}"
  source_dest_check = false

  # this always needs to be true, if use_nat_gateway_eip is set, the ephemeral address will not be used
  # see https://github.com/hashicorp/terraform/issues/9811 for more detail than you want
  associate_public_ip_address = true

  subnet_id = "${aws_subnet.az1_public.id}"

  vpc_security_group_ids = ["${aws_security_group.local_vpc_traffic.id}"]

  tags {
    Name = "${var.stack_description} (AZ1 2017-09 NAT)"
  }
}
resource "aws_instance" "az2_private_nat_2017_09" {
  ami = "ami-4b98182a"
  instance_type = "${var.nat_gateway_instance_type}"
  source_dest_check = false

  # this always needs to be true, if use_nat_gateway_eip is set, the ephemeral address will not be used
  # see https://github.com/hashicorp/terraform/issues/9811 for more detail than you want
  associate_public_ip_address = true

  subnet_id = "${aws_subnet.az2_public.id}"

  vpc_security_group_ids = ["${aws_security_group.local_vpc_traffic.id}"]

  tags {
    Name = "${var.stack_description}  (AZ2 2017-09 NAT)"
  }
}

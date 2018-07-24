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
    Name = "${var.stack_description} (Private Route Table AZ1)"
  }
}

resource "aws_route_table" "az2_private_route_table" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name = "${var.stack_description} (Private Route Table AZ2)"
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

resource "aws_route" "az1_nat_service_route" {
  route_table_id         = "${aws_route_table.az1_private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.az1_private_nat_service.id}"
}

resource "aws_route" "az2_nat_service_route" {
  route_table_id         = "${aws_route_table.az2_private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.az2_private_nat_service.id}"
}

resource "aws_eip" "az1_nat_eip" {
  vpc   = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "az2_nat_eip" {
  vpc   = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip_association" "az1_nat_eip_association" {
  instance_id   = "${aws_instance.az1_private_nat_2017_09.id}"
  allocation_id = "${aws_eip.az1_nat_eip.id}"
}

resource "aws_eip_association" "az2_nat_eip_association" {
  instance_id   = "${aws_instance.az2_private_nat_2017_09.id}"
  allocation_id = "${aws_eip.az2_nat_eip.id}"
}

resource "aws_nat_gateway" "az1_private_nat_service" {
  allocation_id = "${aws_eip.az1_nat_eip.id}"
  subnet_id     = "${aws_subnet.az1_public.id}"

  tags {
    Name = "Nat Service AZ1 ${var.stack_description}"
  }
}

resource "aws_nat_gateway" "az2_private_nat_service" {
  allocation_id = "${aws_eip.az2_nat_eip.id}"
  subnet_id     = "${aws_subnet.az2_public.id}"

  tags {
    Name = "Nat Service AZ2 ${var.stack_description}"
  }
}

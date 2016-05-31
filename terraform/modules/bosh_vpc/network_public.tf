/*
 * Variables required:
 *  stack_description
 *  az1
 *  az2
 *  public_cidr_1
 *  public_cidr_2
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_subnet" "az1_public" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.public_cidr_1}"
  availability_zone = "${var.az1}"

  tags =  {
    Name = "${var.stack_description} (Public AZ1)"
  }
}

resource "aws_subnet" "az2_public" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.public_cidr_2}"
  availability_zone = "${var.az2}"

  tags =  {
    Name = "${var.stack_description} (Public AZ2)"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name = "${var.stack_description} (Gateway)"
  }
}

resource "aws_route_table" "public_network" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "${var.stack_description} (Public Route Table)"
  }
}

resource "aws_route_table_association" "az1_public_rta" {
  subnet_id = "${aws_subnet.az1_public.id}"
  route_table_id = "${aws_route_table.public_network.id}"
}

resource "aws_route_table_association" "az2_public_rta" {
  subnet_id = "${aws_subnet.az2_public.id}"
  route_table_id = "${aws_route_table.public_network.id}"
}

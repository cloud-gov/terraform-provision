
/*
 * Variables required:
 *  stack_description
 *  az1
 *  az2
 *  private_cidr_1
 *  private_cidr_2
 *  nat_gateway_instance_type
 *  nat_gateway_ami
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */


resource "aws_subnet" "az1_private" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.private_cidr_1}"
  availability_zone = "${var.az1}"


  tags =  {
    Name = "${var.stack_description} (Private AZ1)"
  }
}

resource "aws_subnet" "az2_private" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.private_cidr_2}"
  availability_zone = "${var.az2}"

  tags =  {
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

resource "aws_route" "az1_nat_route" {
    route_table_id = "${aws_route_table.az1_private_route_table.id}"
    destination_cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.az1_private_nat.id}"
}

resource "aws_route" "az2_nat_route" {
    route_table_id = "${aws_route_table.az2_private_route_table.id}"
    destination_cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.az2_private_nat.id}"
}

resource "aws_route_table_association" "az1_private_rta" {
  subnet_id = "${aws_subnet.az1_private.id}"
  route_table_id = "${aws_route_table.az1_private_route_table.id}"
}

resource "aws_route_table_association" "az2_private_rta" {
  subnet_id = "${aws_subnet.az2_private.id}"
  route_table_id = "${aws_route_table.az2_private_route_table.id}"
}


resource "aws_instance" "az1_private_nat" {
  ami = "${var.nat_gateway_ami}"
  instance_type = "${var.nat_gateway_instance_type}"
  source_dest_check = false
  associate_public_ip_address = true

  subnet_id = "${aws_subnet.az1_public.id}"

  vpc_security_group_ids = ["${aws_security_group.local_vpc_traffic.id}"]

  tags {
    Name = "${var.stack_description} (AZ1 NAT)"
  }
}

resource "aws_instance" "az2_private_nat" {
  ami = "${var.nat_gateway_ami}"
  instance_type = "${var.nat_gateway_instance_type}"
  source_dest_check = false
  associate_public_ip_address = true

  subnet_id = "${aws_subnet.az2_public.id}"

  vpc_security_group_ids = ["${aws_security_group.local_vpc_traffic.id}"]

  tags {
    Name = "${var.stack_description}  (AZ2 NAT)"
  }
}

output "private_subnet_az1" {
  value = "${aws_subnet.az1_private.id}"
}

output "private_subnet_az2" {
  value = "${aws_subnet.az2_private.id}"
}

output "private_route_table_az1" {
  value = "${aws_route_table.az1_private_route_table.id}"
}

output "private_route_table_az2" {
  value = "${aws_route_table.az2_private_route_table.id}"
}


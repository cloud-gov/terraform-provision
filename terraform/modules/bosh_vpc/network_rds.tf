
resource "aws_subnet" "az1_rds" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.rds_private_cidr_1}"
  availability_zone = "${var.az1}"


  tags =  {
    Name = "${var.stack_description} (RDS AZ1)"
  }
}

resource "aws_subnet" "az2_rds" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.rds_private_cidr_2}"
  availability_zone = "${var.az2}"


  tags =  {
    Name = "${var.stack_description} (RDS AZ2)"
  }
}

output "rds_subnet_az1" {
    value = "aws_subnet.az1_rds.id"
}

output "rds_subnet_az2" {
    value = "aws_subnet.az2_rds.id"
}
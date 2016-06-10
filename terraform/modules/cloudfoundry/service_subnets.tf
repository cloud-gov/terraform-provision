resource "terraform_remote_state" "target_vpc" {
    backend = "s3"
    config {
        bucket = "${var.remote_state_bucket}"
        key = "${var.target_stack_name}/terraform.tfstate"
    }
}


/*
 * Variables required:
 *  stack_description
 *  az1
 *  az2
 *  services_cidr_1
 *  services_cidr_2
 *
 */


resource "aws_subnet" "az1_services" {
  vpc_id = "${terraform_remote_state.target_vpc.output.vpc_id}"
  cidr_block = "${var.services_cidr_1}"
  availability_zone = "${var.az1}"


  tags =  {
    Name = "${var.stack_description} (Services AZ1)"
  }
}

resource "aws_subnet" "az2_services" {
  vpc_id = "${terraform_remote_state.target_vpc.output.vpc_id}"
  cidr_block = "${var.services_cidr_2}"
  availability_zone = "${var.az2}"

  tags =  {
    Name = "${var.stack_description} (Services AZ2)"
  }
}

resource "aws_route_table_association" "az1_services_rta" {
  subnet_id = "${aws_subnet.az1_services.id}"
  route_table_id = "${terraform_remote_state.target_vpc.output.private_route_table_az1}"
}

resource "aws_route_table_association" "az2_services_rta" {
  subnet_id = "${aws_subnet.az2_services.id}"
  route_table_id = "${terraform_remote_state.target_vpc.output.private_route_table_az2}"
}

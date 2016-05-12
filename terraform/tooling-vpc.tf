variable "ACCESS_KEY_ID" {}
variable "SECRET_ACCESS_KEY" {}
variable "DEFAULT_REGION" {
  default = "us-gov-west-1"
}

variable "DESCRIPTION" {
	default = "terraform created tooling"
}

variable "VPC_CIDR" {
	default = "10.99.0.0/16"
}

variable AZ1 {
	default = "us-gov-west-1a"
}

variable AZ2 {
	default = "us-gov-west-1b"
}

variable "AZ1_PUBLIC_CIDR" {
	default = "10.99.100.0/24"
}

variable "AZ2_PUBLIC_CIDR" {
	default = "10.99.101.0/24"
}

variable "AZ1_PRIVATE_CIDR" {
	default = "10.99.1.0/24"
}

variable "AZ2_PRIVATE_CIDR" {
	default = "10.99.2.0/24"
}

variable "AZ1_RDS_CIDR" {
	default = "10.99.20.0/24"
}

variable "AZ2_RDS_CIDR" {
	default = "10.99.21.0/24"
}

variable NAT_GATEWAY_SIZE {
	# ["t2.micro", "m4.large", "m4.xlarge", "m4.10xlarge"]
	default = "t2.micro"
}

variable NAT_GATEWAY_AMI {
	default = "ami-e8ab1489"
}


provider "aws" {
  access_key = "${var.ACCESS_KEY_ID}"
  secret_key = "${var.SECRET_ACCESS_KEY}"
  region = "${var.DEFAULT_REGION}"
}

resource "aws_vpc" "main" {
    cidr_block = "${var.VPC_CIDR}"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags =  {
    	Name = "${var.DESCRIPTION}"
    }

}

resource "aws_subnet" "az1_public" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.AZ1_PUBLIC_CIDR}"
    availability_zone = "${var.AZ1}"

    tags =  {
    	Name = "${var.DESCRIPTION}"
    }
}

resource "aws_subnet" "az2_public" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.AZ2_PUBLIC_CIDR}"
    availability_zone = "${var.AZ2}"

    tags =  {
    	Name = "${var.DESCRIPTION}"
    }
}

resource "aws_subnet" "az1_private" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.AZ1_PRIVATE_CIDR}"
    availability_zone = "${var.AZ1}"


    tags =  {
    	Name = "${var.DESCRIPTION}"
    }
}

resource "aws_subnet" "az2_private" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.AZ2_PRIVATE_CIDR}"
	availability_zone = "${var.AZ2}"

    tags =  {
    	Name = "${var.DESCRIPTION}"
    }
}

resource "aws_subnet" "az1_rds" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.AZ1_RDS_CIDR}"
    availability_zone = "${var.AZ1}"


    tags =  {
    	Name = "${var.DESCRIPTION}"
    }
}

resource "aws_subnet" "az2_rds" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.AZ2_RDS_CIDR}"
    availability_zone = "${var.AZ2}"


    tags =  {
    	Name = "${var.DESCRIPTION}"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"

  	tags {
        Name = "${var.DESCRIPTION}"
    }
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

  	tags {
        Name = "${var.DESCRIPTION}"
    }
}

resource "aws_route_table_association" "az1_public" {
    subnet_id = "${aws_subnet.az1_public.id}"
    route_table_id = "${aws_route_table.public.id}"

}

resource "aws_route_table_association" "az2_public" {
    subnet_id = "${aws_subnet.az2_public.id}"
    route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table" "az1_private" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

  	tags {
        Name = "${var.DESCRIPTION}"
    }
}

resource "aws_route_table" "az2_private" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

  	tags {
        Name = "${var.DESCRIPTION}"
    }
}

resource "aws_route_table_association" "az1_private" {
    subnet_id = "${aws_subnet.az1_public.id}"
    route_table_id = "${aws_route_table.az1_private.id}"
}

resource "aws_route_table_association" "az2_private" {
    subnet_id = "${aws_subnet.az2_public.id}"
    route_table_id = "${aws_route_table.az2_private.id}"
}


resource "aws_instance" "az1_prviate_nat" {
    ami = "${var.NAT_GATEWAY_AMI}"
    instance_type = "${var.NAT_GATEWAY_SIZE}"
    source_dest_check = false
    associate_public_ip_address = true
    delete_on_termination = true

    subnet_id = "${aws_subnet.az1_public.id}"

    vpc_security_group_ids = ["${aws_security_group.local_traffic.id}"]

  	tags {
        Name = "${var.DESCRIPTION}"
    }
}

resource "aws_instance" "az2_prviate_nat" {
    ami = "${var.NAT_GATEWAY_AMI}"
    instance_type = "${var.NAT_GATEWAY_SIZE}"
    source_dest_check = false
    associate_public_ip_address = true
    delete_on_termination = true

    subnet_id = "${aws_subnet.az2_public.id}"

    vpc_security_group_ids = ["${aws_security_group.local_traffic.id}"]

  	tags {
        Name = "${var.DESCRIPTION}"
    }
}

resource "aws_security_group" "local_traffic" {
  description = "Enable access to local ips"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["${var.VPC_CIDR}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["${var.VPC_CIDR}"]
  }
}


resource "aws_security_group" "web_traffic" {
  description = "Enable access to local ips"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 4443
      to_port = 4443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "bosh" {
  description = "Enable access to local ips"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 4222
      to_port = 4222
      protocol = "tcp"
      cidr_blocks = ["${var.VPC_CIDR}"]
  }

  ingress {
      from_port = 6868
      to_port = 6868
      protocol = "tcp"
      cidr_blocks = ["${var.VPC_CIDR}"]
  }
  ingress {
      from_port = 53
      to_port = 53
      protocol = "tcp"
      cidr_blocks = ["${var.VPC_CIDR}"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${var.VPC_CIDR}"]
  }

}




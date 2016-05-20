variable "vpc_cidr" {
  default = "10.99.0.0/16"
}

variable "stack_description" {
  default = "tooling"
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "public_cidr_1" {
  default = "10.99.100.0/24"
}

variable "public_cidr_2" {
  default = "10.99.101.0/24"
}

variable "private_cidr_1" {
  default = "10.99.1.0/24"
}

variable "private_cidr_2" {
  default = "10.99.2.0/24"
}

variable "rds_private_cidr_1" {
  default = "10.99.20.0/24"
}

variable "rds_private_cidr_2" {
  default = "10.99.21.0/24"
}

variable "nat_gateway_instance_type" {
  default = "t2.micro"
}

variable "nat_gateway_ami" {
  default = "ami-e8ab1489"
}
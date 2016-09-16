variable "concourse_password" {}

variable "concourse_username" {
  default = "ci"
}

variable "aws_default_region" {
    default = "us-gov-west-1"
}

variable "aws_partition" {}

variable "ami_id" {
  default = "ami-a32c93c2"
}

variable "instance_type" {
  default = "m3.large"
}

variable "credentials_bucket" {}

variable "aws_access_key_id" {}

variable "aws_secret_access_key" {}

variable "remote_state_bucket" {
  default = "terraform-state"
}

variable "default_vpc_id" {}

variable "default_vpc_cidr" {}

variable "default_vpc_route_table" {}

variable "account_id" {}

variable "concourse_password" {}

variable "concourse_username" {
  default = "ci"
}

variable "aws_default_region" {
    default = "us-gov-west-1"
}

variable "ami_id" {
  default = "ami-a32c93c2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "credentials_bucket" {}

variable "aws_access_key_id" {}

variable "aws_secret_access_key" {}
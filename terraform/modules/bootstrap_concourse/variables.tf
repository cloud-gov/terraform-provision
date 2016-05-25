variable "concourse_password" {}

variable "concourse_username" {
  default = "ci"
}

variable "ami_id" {
  default = "ami-392c9358"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "region" {
  default = "us-gov-west-1"
}
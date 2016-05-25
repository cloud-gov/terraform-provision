variable "concourse_password" {}

variable "default_region" {
  default = "us-gov-west-1"
}

variable "concourse_username" {
  default = "ci"
}

variable "ami_id" {
  default = "ami-392c9358"
}

variable "instance_type" {
  default = "t2.micro"
}

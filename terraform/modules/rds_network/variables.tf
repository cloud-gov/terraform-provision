
variable "stack_description" {
  default = "tooling"
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "rds_private_cidr_1" {
  default = "10.99.20.0/24"
}

variable "rds_private_cidr_2" {
  default = "10.99.21.0/24"
}

variable "vpc_id" {}
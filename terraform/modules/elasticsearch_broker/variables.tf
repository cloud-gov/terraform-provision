variable "stack_description" {
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "elasticsearch_private_cidr_1" {
}

variable "elasticsearch_private_cidr_2" {
}

variable "elasticsearch_private_cidr_3" {
}

variable "elasticsearch_private_cidr_4" {
}

variable "az1_route_table" {
}

variable "az2_route_table" {
}

variable "vpc_id" {
}

variable "security_groups" {
  type = list(string)
}


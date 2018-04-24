variable "stack_description" {}

variable "monitoring_cidr" {
  default = "10.99.30.0/24"
}

variable "monitoring_az" {
  default = "us-gov-west-1a"
}

variable "route_table_id" {}

variable "vpc_id" {}

variable "listener_arn" {}

variable "hosts" {
  type = "list"
}

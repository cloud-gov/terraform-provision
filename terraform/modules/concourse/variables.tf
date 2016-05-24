
variable "stack_description" {
  default = "tooling"
}

variable "concourse_cidr" {
  default = "10.99.30.0/24"
}

variable "concourse_az" {
  default = "us-gov-west-1a"
}

variable "rds_db_name" {
  default = "atc"
}

variable "rds_db_size" {
  default = 10
}

variable "rds_username" {
  default = "atc"
}

variable "rds_password" {}

variable "rds_subnet_group" {}

variable "rds_security_groups" {}

variable "route_table_id" {}

variable "vpc_id" {}

variable "account_id" {}

variable "elb_cert_name" {}

variable "elb_subnets" {}

variable "elb_security_groups" {}
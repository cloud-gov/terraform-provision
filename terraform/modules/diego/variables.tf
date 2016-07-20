
variable "stack_description" {}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "rds_private_cidr_1" {
  default = "10.0.20.0/24"
}

variable "rds_private_cidr_2" {
  default = "10.0.21.0/24"
}

variable "az1_route_table" {}

variable "az2_route_table" {}

variable "vpc_id" {}

variable "elb_main_cert_name" {}

variable "elb_subnets" {}

variable "elb_security_groups" {}

variable "account_id" {}

variable "rds_instance_type" {
    default = "db.m3.large"
}

ariable "rds_db_size" {
    default = 100
}

variable "rds_db_name" {
    default = "diegodb"
}

variable "rds_db_engine" {
    default = "mysql"
}

variable "rds_db_engine_version" {
    default = "5.7.11"
}

variable "rds_username" {
    default = "diegodb"
}

variable "rds_password" {}

variable "rds_subnet_group" {}

variable "rds_security_groups" {}






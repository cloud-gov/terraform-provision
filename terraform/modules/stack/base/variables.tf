variable "stack_description" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "aws_default_region" {
    default = "us-gov-west-1"
}

variable "public_cidr_1" {
  default = "10.0.100.0/24"
}

variable "public_cidr_2" {
  default = "10.0.101.0/24"
}

variable "private_cidr_1" {
  default = "10.0.1.0/24"
}

variable "private_cidr_2" {
  default = "10.0.2.0/24"
}

variable "nat_gateway_instance_type" {
  default = "t2.micro"
}

variable "rds_private_cidr_1" {
  default = "10.0.20.0/24"
}

variable "rds_private_cidr_2" {
  default = "10.0.21.0/24"
}

variable "rds_instance_type" {
    default = "db.m3.medium"
}

variable "rds_db_size" {
    default = 5
}

variable "rds_db_name" {
    default = "bosh"
}

variable "rds_db_engine" {
    default = "postgres"
}

variable "rds_db_engine_version" {
    default = "9.6.2"
}

variable "rds_username" {
    default = "bosh"
}

variable "rds_password" {}

variable "restricted_ingress_web_cidrs" {
    default = "127.0.0.1/32,192.168.0.1/24"
}

variable "rds_security_groups" {
  type = "list"
}

variable "target_monitoring_security_group" {
  default = ""
}
variable "target_monitoring_security_group_count" {
  default = 0
}

variable "target_concourse_security_groups" {
  type = "list"
  default = []
}
variable "target_concourse_security_group_count" {
  default = "0"
}

variable "elb_main_cert_name" {}

variable "elb_apps_cert_name" {}

variable "elb_subnets" {}

variable "elb_security_groups" {}

variable "monitoring_elb_cert_name" {}

variable "logsearch_elb_cert_name" {}

variable "stack_description" {}

variable "account_id" {}

variable "rds_instance_type" {
    default = "db.m3.large"
}

variable "rds_db_size" {
    default = 100
}

variable "rds_db_name" {
    default = "ccdb"
}

variable "rds_db_engine" {
    default = "postgres"
}

variable "rds_db_engine_version" {
    default = "9.4.5"
}

variable "rds_username" {
    default = "cfdb"
}

variable "rds_password" {}

variable "rds_subnet_group" {}

variable "rds_security_groups" {}

variable "stack_prefix" {}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "vpc_id" {}

variable "private_route_table_az1" {}

variable "private_route_table_az2" {}

variable "services_cidr_1" {
  default = "10.0.30.0/24"
}

variable "services_cidr_2" {
  default = "10.0.31.0/24"
}

variable "aws_partition" {}

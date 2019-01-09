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

variable "private_cidr_1" {}

variable "private_cidr_2" {}

variable "nat_gateway_instance_type" {
  default = "c3.2xlarge"
}

variable "rds_private_cidr_1" {}

variable "rds_private_cidr_2" {}

variable "rds_instance_type" {
    default = "db.m4.large"
}

variable "rds_db_size" {
    default = 20
}

variable "rds_db_name" {
    default = "bosh"
}

variable "rds_db_engine" {
    default = "postgres"
}

variable "rds_db_engine_version" {
    default = "9.6.10"
}

variable "rds_username" {
    default = "bosh"
}

variable "rds_password" {}

variable "restricted_ingress_web_cidrs" {
  type = "list"
  default = ["127.0.0.1/32","192.168.0.1/24"]
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type = "list"
  default = []
}

variable "rds_security_groups" {
  type = "list"
}

variable "rds_security_groups_count" {
  default = "0"
}

variable "target_monitoring_security_groups" {
  type = "list"
  default = []
}

variable "target_concourse_security_groups" {
  type = "list"
  default = []
}

variable "rds_multi_az" {
  default = "true"
}

/*
 * CredHub database variables
 */
variable "credhub_rds_db_name" {
  default = "credhub"
}

variable "credhub_rds_db_storage_type" {
  default = "gp2"
}

variable "credhub_rds_instance_type" {
  default = "db.t2.medium"
}

variable "credhub_rds_db_size" {
  default = 100
}

variable "credhub_rds_username" {
    default = "credhub"
}

variable "credhub_rds_password" {}

variable "credhub_rds_db_engine_version" {
  default = "9.6.10"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "credhub_rds_force_ssl" {
  default = 1
}

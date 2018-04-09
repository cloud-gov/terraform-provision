variable "stack_description" {}

variable "concourse_cidr" {
  default = "10.0.30.0/24"
}

variable "concourse_az" {
  default = "us-gov-west-1a"
}

variable "rds_db_name" {
  default = "atc"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_db_size" {
  default = 100
}

variable "rds_db_iops" {
	default = 1000
}

variable "rds_db_storage_type" {
  default = "io1"
}

variable "rds_instance_type" {
  default = "db.m3.xlarge"
}

variable "rds_engine_version" {
  default = "9.6.3"
}

variable "rds_username" {
  default = "atc"
}

variable "rds_password" {}

variable "rds_subnet_group" {}

variable "rds_security_groups" {
  type = "list"
}

variable "rds_multi_az" {}

variable "rds_final_snapshot_identifier" {}

variable "route_table_id" {}

variable "vpc_id" {}

variable "listener_arn" {}

variable "hosts" {
  type = "list"
}

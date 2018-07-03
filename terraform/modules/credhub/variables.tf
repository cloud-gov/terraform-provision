variable "stack_description" {}

variable "credhub_cidr" {
  default = "10.0.30.0/24"
}

variable "credhub_az" {
  default = "us-gov-west-1a"
}

variable "rds_db_name" {
  default = "credhub"
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
  default = "db.m4.xlarge"
}

variable "rds_engine_version" {
  default = "9.6.3"
}

variable "rds_username" {
  default = "credhub"
}

variable "rds_password" {}

variable "rds_subnet_group" {}

variable "rds_security_groups" {
  type = "list"
}

variable "rds_multi_az" {}


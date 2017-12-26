variable "stack_description" {}

variable "rds_instance_type" {
  default = "db.m3.medium"
}

variable "rds_db_size" {
  default = 5
}

variable "rds_db_storage_type" {
  default = "gp2"
}

variable "rds_db_iops" {
  default = 0
}

variable "rds_db_name" {}

variable "rds_db_engine" {
  default = "postgres"
}

variable "rds_db_engine_version" {
  default = "9.6.3"
}

variable "rds_username" {}

variable "rds_password" {}

variable "rds_subnet_group" {}

variable "rds_security_groups" {
  type = "list"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_parameter_group_family" {
  default = "postgres9.6"
}

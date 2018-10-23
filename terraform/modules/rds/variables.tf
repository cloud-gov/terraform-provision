variable "stack_description" {}

variable "rds_instance_type" {
  default = "db.m4.large"
}

variable "rds_db_size" {
  default = 20
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
  default = "9.6.5"
}

variable "rds_username" {}

variable "rds_password" {}

variable "rds_subnet_group" {}

variable "rds_security_groups" {
  type = "list"
}

variable "rds_force_ssl" {
  default = 0
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_parameter_group_family" {
  default = "postgres9.6"
}

variable "rds_multi_az" {
  default = "true"
}

variable "rds_final_snapshot_identifier" {
  default = ""
}

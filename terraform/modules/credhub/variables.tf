variable "stack_description" {}


variable "rds_db_name" {
  default = "credhub"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_db_size" {
  default = 100
}

variable "rds_db_storage_type" {
  default = "gp2"
}

variable "rds_instance_type" {
  default = "db.t2.medium"
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


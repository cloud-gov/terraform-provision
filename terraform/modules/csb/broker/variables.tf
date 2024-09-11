variable "stack_description" {
  type        = string
  description = "Like development, staging, or production."
}

# RDS variables

variable "rds_instance_type" {
  type    = string
  default = "db.t3.small"
}

variable "rds_db_size" {
  type    = string
  default = 20
}

variable "rds_db_name" {
  type    = string
  default = "csb"
}

variable "rds_db_engine" {
  type    = string
  default = "mysql"
}

variable "rds_db_engine_version" {
  type    = string
  default = "8.0"
}

variable "rds_parameter_group_family" {
  type    = string
  default = "mysql8.0"
}

variable "rds_username" {
  type    = string
  default = "csb"
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_subnet_group" {
}

variable "rds_security_groups" {
  type = list(string)
}

variable "rds_apply_immediately" {
  default = "false"
}

variable "rds_allow_major_version_upgrade" {
  default = "false"
}

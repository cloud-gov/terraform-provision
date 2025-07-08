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
  type    = number
  default = 20
}

variable "rds_username" {
  type = string
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

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

variable "rds_db_name" {
  type    = string
  default = "csb"
}

variable "rds_db_engine" {
  type    = string
  default = "mysql"
}

variable "rds_db_engine_version" {
  description = <<-EOT
    Per Cloud.gov cybersecurity, all MySQL DBs within our boundary must
    adhere to STIG standards. Per stighub.com and stigviewer.com, only MySQL 8.0
    has published standards as of 2026-09-02
  EOT
  type        = string
  default     = "8.4"
}

variable "rds_parameter_group_family" {
  type    = string
  default = "mysql8.4"
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

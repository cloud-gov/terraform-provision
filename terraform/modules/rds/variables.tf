variable "stack_description" {
}

variable "rds_instance_type" {
  default = "db.m5.large"
}

variable "rds_db_size" {
  default = 20
}

variable "rds_db_storage_type" {
  default = "gp3"
}

variable "rds_db_iops" {
  default = null
}

variable "rds_db_name" {
}

variable "rds_db_engine" {
  default = "postgres"
}

variable "rds_db_engine_version" {
  default = "12.17"
}

variable "rds_username" {
}

variable "rds_password" {
  sensitive = true
}

variable "rds_subnet_group" {
}

variable "rds_security_groups" {
  type = list(string)
}

variable "rds_force_ssl" {
  default = 0
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_multi_az" {
  default = "true"
}

variable "rds_final_snapshot_identifier" {
  default = ""
}

# Used in combination, these two flags allow for immediate upgrade of RDS
# instances across major versions. They should be used temporarily:
#
# 1. Set both to `true` and apply the configuration.
# 1. Upgrade the DB version and apply.
# 1. Set both to `false` and apply a third time.
#
# Also, please be cautious when upgrading, and follow the documented best
# practices:
#
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html#USER_UpgradeDBInstance.PostgreSQL.MajorVersion.Process
# https://aws.amazon.com/blogs/database/best-practices-for-upgrading-amazon-rds-to-major-and-minor-versions-of-postgresql/
#
variable "rds_apply_immediately" {
  # Even though the documentation says these default to "false", `terraform
  # plan` shows otherwise.
  default = "false"
}

variable "rds_allow_major_version_upgrade" {
  default = "false"
}

variable "performance_insights_enabled" {
  default = "false"
}

variable "rds_add_pgaudit_to_shared_preload_libraries" {
  description = "Whether to enable pgaudit in shared_preload_libraries"
  type        = bool
  default     = false
}

variable "rds_add_pgaudit_log_parameter" {
  description = "Whether to configure the pgaudit.log parameter.  Requires add_pgaudit_to_shared_preload_libraries to apply the setting."
  type        = bool
  default     = false
}

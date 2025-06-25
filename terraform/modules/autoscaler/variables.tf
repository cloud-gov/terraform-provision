variable "stack_description" {
}

variable "rds_instance_type" {
  default = "db.t3.small"
}

variable "rds_db_size" {
  default = 20
}

variable "rds_db_name" {
  default = "autoscaler"
}

variable "rds_db_engine" {
  default = "postgres"
}

variable "rds_db_engine_version" {
  default = "15.7"
}

variable "rds_parameter_group_family" {
  default = "postgres15"
}

variable "rds_username" {
  default = "ascaler"
}

variable "rds_password" {
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

variable "rds_add_pgaudit_to_shared_preload_libraries_autoscaler" {
  description = "Whether to enable pgaudit in shared_preload_libraries"
  type        = bool
  default     = false
}

variable "rds_add_pgaudit_log_parameter_autoscaler" {
  description = "Whether to configure the pgaudit.log parameter.  Requires add_pgaudit_to_shared_preload_libraries to apply the setting."
  type        = bool
  default     = false
}

variable "rds_shared_preload_libraries_autoscaler" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_autoscaler" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_add_log_replication_commands_autoscaler" {
  description = "Whether to enable the log_replication_commands parameter."
  type        = bool
  default     = false
}

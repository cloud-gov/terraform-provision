variable "stack_description" {
}

variable "defectdojo_cidr_az1" {
  default = "10.0.30.0/24"
}
variable "defectdojo_cidr_az2" {
  default = "10.0.31.0/24"
}

variable "defectdojo_az1" {
  default = "us-gov-west-1a"
}

variable "defectdojo_az2" {
  default = "us-gov-west1b"
}

variable "rds_db_name" {
  default = "dojo"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_parameter_group_family" {
  default = "postgres16"
}

variable "rds_db_size" {
  default = 200
}

variable "rds_db_iops" {
  default = 0
}

variable "rds_db_storage_type" {
  default = "gp2"
}

variable "rds_instance_type" {
  default = "db.m5.large"
}

variable "rds_db_engine_version" {
  default = "16.3"
}

variable "rds_username" {
  default = "dojo"
}

variable "rds_password" {
  sensitive = true
}

variable "rds_subnet_group" {
}

variable "rds_security_groups" {
  type = list(string)
}

variable "rds_multi_az" {
}

variable "rds_final_snapshot_identifier" {
}

variable "rds_allow_major_version_upgrade" {
}

variable "rds_apply_immediately" {
}

variable "route_table_id_az1" {
}

variable "route_table_id_az2" {
}

variable "vpc_id" {
}

variable "listener_arn" {
}

variable "hosts" {
  type = list(string)
}

variable "rds_force_ssl" {
  default = 1
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

variable "rds_shared_preload_libraries" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_add_log_replication_commands" {
  description = "Whether to enable the log_replication_commands parameter."
  type        = bool
  default     = false
}

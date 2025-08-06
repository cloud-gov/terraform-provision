variable "stack_description" {
}

variable "credhub_cidr_az1" {
  default = "10.0.30.0/24"
}

variable "credhub_cidr_az2" {
  default = "10.0.31.0/24"
}

variable "credhub_az1" {
  default = "us-gov-west-1a"
}

variable "credhub_az2" {
  default = "us-gov-west-1b"
}

variable "rds_db_name" {
  default = "credhub"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_db_size" {
  default = 200
}

variable "rds_db_iops" {
  default = null
}

variable "rds_db_storage_type" {
  default = "gp3"
}

variable "rds_instance_type" {
  default = "db.m5.xlarge"
}

variable "rds_db_engine_version" {
  default = "12.17"
}

variable "rds_username" {
  default = "atc"
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


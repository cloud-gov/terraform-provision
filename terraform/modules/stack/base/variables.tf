variable "stack_description" {
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "public_cidr_1" {
  default = "10.0.100.0/24"
}

variable "public_cidr_2" {
  default = "10.0.101.0/24"
}

variable "private_cidr_1" {
}

variable "private_cidr_2" {
}

variable "nat_gateway_instance_type" {
  default = "c3.2xlarge"
}

variable "rds_private_cidr_1" {
}

variable "rds_private_cidr_2" {
}

variable "rds_private_cidr_3" {
}

variable "rds_private_cidr_4" {
}

variable "rds_instance_type" {
  default = "db.m5.large"
}

variable "rds_db_size" {
  default = 20
}

variable "rds_allow_major_version_upgrade" {
  default = "false"
}

variable "rds_apply_immediately" {
  default = "false"
}

variable "rds_db_name" {
  default = "bosh"
}

variable "rds_db_engine" {
  default = "postgres"
}

variable "rds_db_engine_version" {
  default = "12.17"
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_username" {
  default = "bosh"
}

variable "rds_password" {
  sensitive = true
}

variable "restricted_ingress_web_cidrs" {
  type    = list(string)
  default = ["127.0.0.1/32", "192.168.0.1/24"]
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type    = list(string)
  default = []
}

variable "rds_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "rds_allowed_cidrs_count" {
  default = "0"
}

variable "rds_security_groups" {
  type = list(string)
}

variable "rds_security_groups_count" {
  default = "0"
}

variable "target_monitoring_security_group_cidrs" {
  type    = list(string)
  default = []
}

variable "target_concourse_security_group_cidrs" {
  type    = list(string)
  default = []
}

variable "target_credhub_security_group_cidrs" {
  type    = list(string)
  default = []
}

variable "rds_multi_az" {
  default = "true"
}

variable "rds_add_pgaudit_to_shared_preload_libraries_bosh" {
  description = "Whether to enable pgaudit in shared_preload_libraries"
  type        = bool
  default     = false
}

variable "rds_add_pgaudit_log_parameter_bosh" {
  description = "Whether to configure the pgaudit.log parameter.  Requires add_pgaudit_to_shared_preload_libraries to apply the setting."
  type        = bool
  default     = false
}

variable "rds_shared_preload_libraries_bosh" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_bosh" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_add_log_replication_commands_bosh" {
  description = "Whether to enable the log_replication_commands parameter."
  type        = bool
  default     = false
}

/*
 * CredHub database variables
 */
variable "credhub_rds_db_name" {
  default = "credhub"
}

variable "credhub_rds_db_storage_type" {
  default = "gp3"
}

variable "credhub_rds_instance_type" {
  default = "db.t3.medium"
}

variable "credhub_rds_db_size" {
  default = 100
}

variable "credhub_rds_username" {
  default = "credhub"
}

variable "credhub_rds_password" {
  sensitive = true
}

variable "credhub_rds_db_engine_version" {
  default = "12.17"
}

variable "credhub_rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "rds_force_ssl" {
  default = 1
}

variable "credhub_rds_force_ssl" {
  default = 1
}

variable "bosh_default_ssh_public_key" {

}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}


variable "cidr_blocks" {
  type    = list(string)
  default = []
}

variable "rds_add_pgaudit_to_shared_preload_libraries_bosh_credhub" {
  description = "Whether to enable pgaudit in shared_preload_libraries"
  type        = bool
  default     = false
}

variable "rds_add_pgaudit_log_parameter_bosh_credhub" {
  description = "Whether to configure the pgaudit.log parameter.  Requires add_pgaudit_to_shared_preload_libraries to apply the setting."
  type        = bool
  default     = false
}

variable "rds_shared_preload_libraries_bosh_credhub" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_bosh_credhub" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_add_log_replication_commands_credhub" {
  description = "Whether to enable the log_replication_commands parameter."
  type        = bool
  default     = false
}

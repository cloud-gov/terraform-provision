variable "stack_description" {
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-gov-west-1a","us-gov-west-1b"]
}


variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "public_cidrs" {
  type    = list(string)
  default = ["10.0.100.0/24","10.0.101.0/24"]
}

variable "private_cidrs" {
  type    = list(string)
}

variable "nat_gateway_instance_type" {
  default = "c3.2xlarge"
}

variable "rds_private_cidrs" {
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
  default = "15.3"
}

variable "rds_parameter_group_family" {
  default = "postgres15"
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

/*
 * CredHub database variables
 */
variable "protobosh_rds_db_name" {
  default = "bosh"
}

variable "protobosh_rds_db_storage_type" {
  default = "gp3"
}

variable "protobosh_rds_instance_type" {
  default = "db.t3.medium"
}

variable "protobosh_rds_db_size" {
  default = 20
}

variable "protobosh_rds_username" {
  default = "bosh"
}

variable "protobosh_rds_password" {
  sensitive = true
}

variable "protobosh_rds_db_engine_version" {
  default = "15.3"
}

variable "protobosh_rds_parameter_group_family" {
  default = "postgres15"
}

variable "rds_parameter_group_name" {
  default = ""
}

variable "protobosh_rds_force_ssl" {
  default = 1
}

variable "protobosh_rds_multi_az" {
  default = "true"
}

variable "protobosh_rds_allow_major_version_upgrade" {
  default = "false"
}

variable "protobosh_rds_apply_immediately" {
  default = "false"
}

variable "create_protobosh_rds" {
  description = "Controls whether to create a protobosh rds (should be true for hubs, false for spokes)"
  type        = bool
  default     = false
}

/*
 * END CredHub database variables
 */

variable "bosh_default_ssh_public_key" {

}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}


variable "rds_force_ssl" {
  default = 1
}

variable "rds_db_storage_type" {
  default = "gp3"
}
variable "stack_description" {
  default = "westa-hub"
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {
}

variable "rds_multi_az" {
  default = "true"
}

variable "rds_allow_major_version_upgrade" {
  default = "false"
}

variable "rds_apply_immediately" {
  default = "false"
}

variable "rds_db_engine_version" {
  default = "15.5"
}

variable "rds_parameter_group_family" {
  default = "postgres15"
}

variable "remote_state_bucket" {
}

variable "wildcard_certificate_name_prefix" {
  default = ""
}

variable "concourse_hosts" {
  type = list(string)
}

variable "credhub_hosts" {
  type = list(string)
}

variable "defectdojo_hosts" {
  type = list(string)
}

variable "monitoring_hosts" {
  type = list(string)
}

variable "nessus_hosts" {
  type = list(string)
}

variable "restricted_ingress_web_cidrs" {
  type = list(string)
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type = list(string)
}

variable "bucket_prefix" {
  default = ""
}

variable "dns_eip_count" {
  default = 2
}

variable "terraform_state_bucket" {
}

variable "smtp_ingress_cidr_blocks" {
  type = list(string)
}

variable "doomsday_oidc_client" {
}

variable "nessus_oidc_client" {
}

variable "nessus_oidc_client_secret" {
}

variable "opslogin_hostname" {
}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}

## New
variable "credhub_rds_instance_type" {
  default = "db.m5.large"
}

variable "concourse_rds_instance_type" {
  default = "db.m5.large"
}

variable "defectdojo_rds_password" {
  sensitive = true
}

variable "cloudtrail_accesslog_bucket" {
  default = "cg-accesslogs"
}


variable "github_backups_bucket_name" {
  type    = string
  default = "github-backups"
}

## Experimental
variable "create_jumpbox" {
  description = "Controls if an ec2 jumpbox is created"
  type        = bool
  default     = true
}

variable "aws_lb_listener_ssl_policy" {
  type    = string
}

variable "stack_description" {
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {
}

variable "rds_db_size" {
  default = 20
}

variable "rds_password" {
}

variable "cf_rds_password" {
}

variable "credhub_rds_password" {
}

variable "remote_state_bucket" {
}

variable "target_stack_name" {
  default = "tooling"
}

variable "wildcard_certificate_name_prefix" {
  default = ""
}

variable "wildcard_apps_certificate_name_prefix" {
  default = ""
}

variable "wildcard_pages_staging_certificate_name_prefix" {
  default = ""
}

variable "wildcard_sites_pages_staging_certificate_name_prefix" {
  default = ""
}

variable "admin_hosts" {
  type = list(string)
}

variable "shibboleth_hosts" {
  type = list(string)
}

variable "platform_kibana_hosts" {
  type = list(string)
}

variable "restricted_ingress_web_cidrs" {
  type = list(string)
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type = list(string)
}

variable "stack_prefix" {
}

variable "bucket_prefix" {
}

variable "blobstore_bucket_name" {
}

variable "upstream_blobstore_bucket_name" {
}

variable "force_restricted_network" {
  default = "yes"
}

variable "log_bucket_name" {
  default = "cg-elb-logs"
}

variable "rds_allow_major_version_upgrade" {
  default = "false"
}

variable "rds_apply_immediately" {
  default = "false"
}

variable "assume_arn" {
  # arn of a role to assume in the account being configured
}
variable "stack_class" {
  # should be one of development, staging, production
}
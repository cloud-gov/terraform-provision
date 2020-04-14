variable "stack_description" {}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {}

variable "rds_db_size" {
  default = 20
}

variable "rds_password" {}

variable "cf_rds_password" {}

variable "credhub_rds_password" {}

variable "remote_state_bucket" {}

variable "target_stack_name" {
  default = "tooling"
}

variable "wildcard_certificate_name_prefix" {
  default = ""
}

variable "wildcard_apps_certificate_name_prefix" {
  default = ""
}

variable "admin_hosts" {
  type = "list"
}

variable "shibboleth_hosts" {
  type = "list"
}

variable "platform_kibana_hosts" {
  type = "list"
}

variable "kubernetes_cluster_id" {}

variable "restricted_ingress_web_cidrs" {
  type = "list"
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type = "list"
}

variable "stack_prefix" {}
variable "bucket_prefix" {}
variable "blobstore_bucket_name" {}
variable "upstream_blobstore_bucket_name" {}

variable "force_restricted_network" {
  default = "yes"
}

variable "log_bucket_name" {
  default = "cg-elb-logs"
}

variable "rds_allow_major_version_upgrade" {
  default = ""
}

variable "rds_apply_immediately" {
  default = ""
}

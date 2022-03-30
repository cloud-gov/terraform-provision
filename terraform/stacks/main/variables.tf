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
variable "rds_instance_type" {
  default = "db.m4.large"
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

variable "pages_cert_patterns" {
  default = []
  type = set(string)
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

variable "parent_assume_arn" {
  # arn of a role to assume in the account the parentbosh lives in
}

variable "parent_stack_name" {
  # stack where the parent bosh lives
  default = "tooling"
}

variable "domains_broker_rds_version" {
  default = "11.12"
}
variable "cf_rds_instance_type" {
  default = "db.m4.large"
}

variable "bosh_default_ssh_public_key" {

}

variable "az1_index" {
  default = "0"
}

variable "az2_index" {
  default = "1"
}

variable "include_tcp_routes" {
  type = bool
  default = false
}

variable "waf_regular_expressions" {
  type = list(string)
}
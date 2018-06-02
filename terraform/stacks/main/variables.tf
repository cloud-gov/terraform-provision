variable "stack_description" {}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {}

variable "rds_password" {}

variable "cf_rds_password" {}

variable "remote_state_bucket" {}

variable "target_stack_name" {
  default = "tooling"
}

variable "main_cert_name" {
  default = ""
}
variable "apps_cert_name" {
  default = ""
}
variable "wildcard_prefix" {
  default = ""
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

variable "18f_gov_elb_cert_name" {
  default = ""
}

variable "elb_shibboleth_cert_name" {
  default = "star-fr-cloud-gov-2017-05"
}

variable "stack_prefix" {}
variable "bucket_prefix" {}
variable "blobstore_bucket_name" {}
variable "upstream_blobstore_bucket_name" {}

variable "force_restricted_network" {
  default = "yes"
}

variable "use_nat_gateway_eip" {
  default = false
}

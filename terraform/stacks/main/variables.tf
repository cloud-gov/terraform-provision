variable "stack_description" {}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {}

variable "public_cidr_1" {}

variable "public_cidr_2" {}

variable "private_cidr_1" {}

variable "private_cidr_2" {}

variable "rds_private_cidr_1" {}

variable "rds_private_cidr_2" {}

variable "elasticache_private_cidr_1" {}

variable "elasticache_private_cidr_2" {}

variable "rds_password" {}

variable "cf_rds_password" {}

variable "remote_state_bucket" {}

variable "target_stack_name" {
  default = "tooling"
}

variable "main_cert_name" {}

variable "apps_cert_name" {}

variable "wildcard_prefix" {}

variable "services_cidr_1" {}
variable "services_cidr_2" {}
variable "kubernetes_cluster_id" {}

variable "restricted_ingress_web_cidrs" {
  type = "list"
}

variable "18f_gov_elb_cert_name" {
  default = ""
}

/* Variables for Diego Deployment */
variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
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

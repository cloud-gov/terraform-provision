variable "stack_description" {
  default = "tooling"
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}
variable "public_cidr_1" {}

variable "public_cidr_2" {}

variable "private_cidr_1" {}

variable "private_cidr_2" {}

variable "rds_private_cidr_1" {}

variable "rds_private_cidr_2" {}

variable "rds_password" {}

variable "rds_multi_az" {
  default = "true"
}

variable "remote_state_bucket" {}

variable "concourse_prod_rds_password" {}
variable "concourse_prod_cidr" {}
variable "concourse_prod_elb_cert_name" {
  default = "star-fr-cloud-gov-2017-05"
}

variable "concourse_staging_rds_password" {}
variable "concourse_staging_cidr" {}
variable "concourse_staging_elb_cert_name" {
  default = "star-fr-stage-cloud-gov-2017-05"
}

variable "monitoring_production_cidr" {}
variable "monitoring_production_elb_cert_name" {
  default = "star-fr-cloud-gov-2017-05"
}

variable "monitoring_staging_cidr" {}
variable "monitoring_staging_elb_cert_name" {
  default = "star-fr-stage-cloud-gov-2017-05"
}

variable "nessus_elb_cert_name" {
  default = "star-fr-cloud-gov-2017-05"
}

variable "bosh_uaa_elb_cert_name" {
  default = "star-fr-cloud-gov-2017-05"
}

variable "wildcard_production_prefix" {
  default = ""
}
variable "wildcard_staging_prefix" {
  default = ""
}

variable "production_cert_name" {
  default = ""
}
variable "use_staging_certificate" {}
variable "staging_cert_name" {
  default = ""
}

variable "concourse_production_hosts" {
  type = "list"
}
variable "concourse_staging_hosts" {
  type = "list"
}

variable "monitoring_production_hosts" {
  type = "list"
}
variable "monitoring_staging_hosts" {
  type = "list"
}

variable "nessus_hosts" {
  type = "list"
}

variable "restricted_ingress_web_cidrs" {
  type = "list"
}

variable "blobstore_bucket_name" {}

variable "bucket_prefix" {
  default = ""
}

variable "dns_eip_count_production" {
  default = 4
}

variable "dns_eip_count_staging" {
  default = 2
}

variable "varz_bucket" {
  default = "cloud-gov-varz"
}

variable "varz_bucket_stage" {
  default = "cloud-gov-varz-stage"
}

variable "bosh_release_bucket" {
  default = "cloud-gov-bosh-releases"
}

variable "terraform_state_bucket" {
  default = "terraform-state"
}

variable "semver_bucket" {
  default = "cg-semver"
}

variable "buildpack_notify_bucket" {
  default = "buildpack-notify-state-*"
}

variable "billing_bucket" {
  default = "cg-billing-*"
}

variable "cg_binaries_bucket" {
   default = "cg-binaries"
}

variable "use_nat_gateway_eip" {
  default = false
}

variable "smtp_ingress_cidr_blocks" {
  type = "list"
}

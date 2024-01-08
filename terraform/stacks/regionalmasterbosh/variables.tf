variable "stack_description" {
  default = "master-east"
}

variable "aws_default_region" {
  default = "us-gov-east-1"
}

variable "vpc_cidr" {
}

variable "rds_password" {
  sensitive = true
}

variable "credhub_rds_password" {
  sensitive = true
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
  default = "12.14"
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "remote_state_bucket" {
}

variable "wildcard_production_certificate_name_prefix" {
  default = ""
}

variable "monitoring_production_hosts" {
  type = list(string)
}

variable "restricted_ingress_web_cidrs" {
  type = list(string)
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type = list(string)
}

variable "blobstore_bucket_name" {
}

variable "bucket_prefix" {
  default = ""
}

variable "bosh_release_bucket" {
  default = "cloud-gov-bosh-releases"
}

variable "smtp_ingress_cidr_blocks" {
  type = list(string)
}

variable "cloudtrail_bucket" {
  default = "cg-s3-cloudtrail"
}

variable "log_bucket_name" {
  default = "cg-elb-logs"
}

variable "oidc_client" {
}

variable "oidc_client_secret" {
}

variable "assume_arn" {
  # arn of a role in the remote account to assume
}

variable "target_stack_name" {
  # name of the stack that ci runs in to bootstrap this stack
  default = "tooling"
}

variable "nessus_hosts" {
  type = list(string)

}

variable "opslogin_hostname" {
  default = "opsuaa.fr.cloud.gov"
}

variable "rds_instance_type" {

}

variable "bosh_default_ssh_public_key" {

}

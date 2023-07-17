variable "stack_description" {
  default = "tooling"
}

variable "aws_default_region" {
  default = "us-gov-west-1"
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

variable "concourse_prod_rds_password" {
  sensitive = true
}

variable "concourse_staging_rds_password" {
  sensitive = true
}

variable "concourse_varz_bucket" {
}

variable "credhub_prod_rds_password" {
  sensitive = true
}

variable "credhub_staging_rds_password" {
  sensitive = true
}

variable "wildcard_production_certificate_name_prefix" {
  default = ""
}

variable "wildcard_staging_certificate_name_prefix" {
  default = ""
}

variable "concourse_production_hosts" {
  type = list(string)
}

variable "concourse_staging_hosts" {
  type = list(string)
}

variable "credhub_production_hosts" {
  type = list(string)
}

variable "credhub_staging_hosts" {
  type = list(string)
}

variable "monitoring_production_hosts" {
  type = list(string)
}

variable "monitoring_staging_hosts" {
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

variable "blobstore_bucket_name" {
}

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

variable "build_artifacts_bucket" {
  default = "cg-build-artifacts"
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

variable "smtp_ingress_cidr_blocks" {
  type = list(string)
}

variable "cloudtrail_bucket" {
  default = "cg-s3-cloudtrail"
}

variable "cloudtrail_accesslog_bucket" {
  default = "cg-accesslogs"
}

variable "log_bucket_name" {
  default = "cg-elb-logs"
}

variable "pgp_keys_bucket_name" {
  default = "cg-pgp-keys"
}

variable "container_scanning_bucket_name" {
  default = "cg-container-scanning"
}

variable "oidc_client" {
}

variable "oidc_client_secret" {
}

variable "opslogin_hostname" {
}

variable "bosh_default_ssh_public_key" {

}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}

variable "github_backups_bucket_name" {
  type    = string
  default = "github-backups"
}

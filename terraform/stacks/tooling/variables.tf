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
  default = "12.19"
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_db_engine_version_bosh" {
  default = "15.5"
}

variable "rds_parameter_group_family_bosh" {
  default = "postgres15"
}

variable "rds_force_ssl_bosh" {
  default = 1
}

variable "rds_db_engine_version_credhub_staging" {
  default = "15.5"
}

variable "rds_parameter_group_family_credhub_staging" {
  default = "postgres15"
}

variable "rds_force_ssl_credhub_staging" {
  default = 1
}

variable "rds_db_engine_version_credhub_production" {
  default = "15.5"
}

variable "rds_parameter_group_family_credhub_production" {
  default = "postgres15"
}

variable "rds_force_ssl_credhub_production" {
  default = 1
}

variable "rds_db_engine_version_concourse_staging" {
  default = "15.5"
}

variable "rds_parameter_group_family_concourse_staging" {
  default = "postgres15"
}

variable "rds_force_ssl_concourse_staging" {
  default = 1
}

variable "rds_db_engine_version_concourse_production" {
  default = "15.5"
}

variable "rds_parameter_group_family_concourse_production" {
  default = "postgres15"
}

variable "rds_force_ssl_concourse_production" {
  default = 1
}

variable "rds_db_engine_version_opsuaa" {
  default = "16.1"
}

variable "rds_parameter_group_family_opsuaa" {
  default = "postgres16"
}

variable "rds_force_ssl_opsuaa" {
  default = 1
}

variable "remote_state_bucket" {
}

variable "concourse_prod_rds_password" {
  sensitive = true
}

variable "concourse_prod_pages_rds_password" {
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

variable "defectdojo_development_rds_password" {
  sensitive = true
}

variable "defectdojo_staging_rds_password" {
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

variable "defectdojo_development_hosts" {
  type = list(string)
}

variable "defectdojo_staging_hosts" {
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

variable "container_scanning_bucket_name" {
  default = "cg-container-scanning"
}

variable "nessus_oidc_client" {
}

variable "nessus_oidc_client_secret" {
}

variable "doomsday_oidc_client" {
}

variable "doomsday_oidc_client_secret" {
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

variable "rds_db_engine_version_bosh_credhub" {
  default = "15.5"
}

variable "rds_parameter_group_family_bosh_credhub" {
  default = "postgres15"
}

variable "aws_lb_listener_ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
}

variable "rds_db_engine_version_defectdojo_development" {
  default = "16.3"
}

variable "rds_parameter_group_family_defectdojo_development" {
  default = "postgres16"
}

variable "rds_force_ssl_defectdojo_development" {
  default = 1
}

variable "rds_db_engine_version_defectdojo_staging" {
  default = "16.3"
}

variable "rds_parameter_group_family_defectdojo_staging" {
  default = "postgres16"
}

variable "rds_force_ssl_defectdojo_staging" {
  default = 1
}

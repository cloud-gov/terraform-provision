variable "stack_description" {
  default = "hub"
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {
}

# Replaced by random_string.rds_password.result
#variable "rds_password" {
#  sensitive = true
#}

# Replaced with random_string.credhub_rds_password.result
#variable "credhub_rds_password" {
#  sensitive = true
#}

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
  default = "12.11"
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "remote_state_bucket" {
}

# Replaced with random_string.concourse_prod_rds_password.result
#variable "concourse_prod_rds_password" {
#  sensitive = true
#}

# Replaced with random_string.concourse_staging_rds_password.result
#variable "concourse_staging_rds_password" {
#  sensitive = true
#}

# Uses default naming now "${var.bucket_prefix}-concourse-credentials"
#variable "concourse_varz_bucket" {
#}

# Replaced with random_string.credhub_prod_rds_password.result
#variable "credhub_prod_rds_password" {
#  sensitive = true
#}

# Replaced with random_string.credhub_staging_rds_password.result
#variable "credhub_staging_rds_password" {
#  sensitive = true
#}

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

# Now assigned by "${var.bucket_prefix}-bosh-blobstore"
#variable "blobstore_bucket_name" {
#}

variable "bucket_prefix" {
  default = ""
}

variable "dns_eip_count_production" {
  default = 4
}

variable "dns_eip_count_staging" {
  default = 2
}

# Uses default naming now "${var.bucket_prefix}-cloud-gov-varz"
#variable "varz_bucket" {
#  default = "cloud-gov-varz-hub"
#}

# Uses default naming now "${var.bucket_prefix}-cloud-gov-varz-stage"
#variable "varz_bucket_stage" {
#  default = "cloud-gov-varz-stage-hub"
#}

# Uses default naming now
#variable "bosh_release_bucket" {
#  default = "hub-cloud-gov-bosh-releases"
#}

variable "terraform_state_bucket" {
  default = "terraform-state-hub"
}

# Uses default naming now "${var.bucket_prefix}-cg-semver"
#variable "semver_bucket" {
#  default = "cg-semver-hub"
#}

# Uses default naming now "${var.bucket_prefix}-cg-build-artifacts"
#variable "build_artifacts_bucket" {
#  default = "hub-cg-build-artifacts"
#}

# Uses default naming now "${var.bucket_prefix}-buildpack-notify-state-*"
#variable "buildpack_notify_bucket" {
#  default = "hub-buildpack-notify-state-*"
#}

# Uses default naming now "${var.bucket_prefix}-cg-billing-*"
#variable "billing_bucket" {
#  default = "" 
#}

# Uses default naming now "${var.bucket_prefix}-cg-binaries"
#variable "cg_binaries_bucket" {
#  default = "hub-cg-binaries"
#}

variable "smtp_ingress_cidr_blocks" {
  type = list(string)
}

# Uses default naming now "${var.bucket_prefix}-cg-s3-cloudtrail"
#variable "cloudtrail_bucket" {
#  default = "cg-s3-cloudtrail"
#}

# Uses default naming now "${var.bucket_prefix}-cg-elb-logs"
#variable "log_bucket_name" {
#  default = "hub-cg-elb-logs"
#}

# Uses default naming now "${var.bucket_prefix}-cg-pgp-keys"
#variable "pgp_keys_bucket_name" {
#  default = "hub-cg-pgp-keys"
#}

# Uses default name now "${var.bucket_prefix}-cg-container-scanning"
#variable "container_scanning_bucket_name" {
#  default = "hub-cg-container-scanning"
#}

variable "oidc_client" {
}

variable "oidc_client_secret" {
}

variable "opslogin_hostname" {
}

# Now created in key_pair.tf
#variable "bosh_default_ssh_public_key" {
#
#}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}

variable "stack_description" {
  default = "westa-hub"
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {
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
  default = "15.5"
}

variable "rds_parameter_group_family" {
  default = "postgres15"
}

variable "remote_state_bucket" {
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

variable "bucket_prefix" {
  default = ""
}

variable "dns_eip_count_production" {
  default = 4
}

variable "dns_eip_count_staging" {
  default = 2
}

variable "terraform_state_bucket" {
  default = "westa-hub-terraform-state"
}

variable "smtp_ingress_cidr_blocks" {
  type = list(string)
}

variable "oidc_client" {
}

variable "opslogin_hostname" {
}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}

## New
variable "credhub_staging_rds_instance_type" {
  default = "db.m5.large"
}

variable "concourse_staging_rds_instance_type" {
  default = "db.m5.large"
}

variable "concourse_production_rds_instance_type" {
  default = "db.m5.xlarge"
}

variable "credhub_production_rds_instance_type" {
  default = "db.m5.large"
}


variable "defectdojo_staging_rds_password" {
  sensitive = true
}


variable "cloudtrail_accesslog_bucket" {
  default = "cg-accesslogs"
}


variable "github_backups_bucket_name" {
  type    = string
  default = "github-backups"
}

## Retired

# Replaced by random_string.rds_password.result
#variable "rds_password" {
#  sensitive = true
#}

# Replaced with random_string.credhub_rds_password.result
#variable "credhub_rds_password" {
#  sensitive = true
#}

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

# Now assigned by "${var.bucket_prefix}-bosh-blobstore"
#variable "blobstore_bucket_name" {
#}

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

# Uses generated password now with random_string.oidc_client_secret.result
#variable "oidc_client_secret" {
#}

# Now created in key_pair.tf
#variable "bosh_default_ssh_public_key" {
#
#}


## Experimental
variable "create_jumpbox" {
  description = "Controls if an ec2 jumpbox is created"
  type        = bool
  default     = true
}

variable "aws_lb_listener_ssl_policy" {
  type = string
  default = "ELBSecurityPolicy-TLS13-1-2-EXT1-2021-06"
}
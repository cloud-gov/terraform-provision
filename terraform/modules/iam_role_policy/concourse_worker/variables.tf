variable "policy_name" {
}

variable "aws_partition" {
}

variable "varz_bucket" {
}

variable "varz_staging_bucket" {
}

variable "bosh_release_bucket" {
}

variable "terraform_state_bucket" {
}

variable "semver_bucket" {
}

variable "buildpack_notify_bucket" {
}

variable "billing_bucket" {
}

variable "cg_binaries_bucket" {
}

variable "log_bucket" {
}

variable "build_artifacts_bucket" {
}

variable "concourse_varz_bucket" {
}

variable "container_scanning_bucket_name" {
  type        = string
  description = "Name of S3 bucket for container scanning config"
}

variable "github_backups_bucket_name" {
  type        = string
  description = "Github Backups bucket"
}

variable "fips_stemcell_bucket" {
  type = string
}


variable "az1" {
    default = "us-gov-west-1a"
}

variable "az2" {
    default = "us-gov-west-1b"
}

variable "remote_state_bucket" {
  default = "terraform-state"
}

variable "account_id" {}

variable "tooling_rds_password" {}

variable "concourse_prod_rds_password" {}

variable "concourse_staging_rds_password" {}

variable "prod_rds_password" {}

variable "staging_rds_password" {}

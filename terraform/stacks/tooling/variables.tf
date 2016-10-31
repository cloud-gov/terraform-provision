
variable "stack_description" {
    default = "tooling"
}

variable "aws_default_region" {
    default = "us-gov-west-1"
}

variable "aws_partition" {
    default = "aws-us-gov"
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

variable "account_id" {}

variable "remote_state_bucket" {}

variable "concourse_prod_rds_password" {}
variable "concourse_prod_cidr" {}
variable "concourse_prod_elb_cert_name" {
    default = "star-fr-cloud-gov-06-16"
}

variable "concourse_staging_rds_password" {}
variable "concourse_staging_cidr" {}
variable "concourse_staging_elb_cert_name" {
    default = "star-fr-staging-cloud-gov-06-16"
}

variable "monitoring_production_cidr" {}
variable "monitoring_production_elb_cert_name" {
    default = "star-fr-cloud-gov-06-16"
}

variable "monitoring_staging_cidr" {}
variable "monitoring_staging_elb_cert_name" {
    default = "star-fr-staging-cloud-gov-06-16"
}

variable "nessus_elb_cert_name" {
	default = "star-fr-cloud-gov-06-16"
}

variable "bosh_uaa_elb_cert_name" {
    default = "star-fr-cloud-gov-06-16"
}

variable "restricted_ingress_web_cidrs" {}

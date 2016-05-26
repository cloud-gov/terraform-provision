
variable "stack_description" {
    default = "tooling"
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

variable "concourse_prod_rds_password" {}
variable "concourse_prod_cidr" {}
variable "concourse_prod_elb_cert_name" {
    default = "cloud-gov"
}

variable "concourse_staging_rds_password" {}
variable "concourse_staging_cidr" {}
variable "concourse_staging_elb_cert_name" {
    default = "cloud-gov"
}
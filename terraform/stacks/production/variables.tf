variable "stack_description" {
    default = "production"
}

variable "aws_partition" {
    default = "aws-us-gov"
}

variable "vpc_cidr" {}

variable "public_cidr_1" {}

variable "public_cidr_2" {}

variable "private_cidr_1" {}

variable "private_cidr_2" {}

variable "rds_private_cidr_1" {}

variable "rds_private_cidr_2" {}

variable "rds_password" {}

variable "cf_rds_password" {}

variable "account_id" {}

variable "remote_state_bucket" {}

variable "target_stack_name" {
    default = "tooling"
}

variable "main_cert_name" {
    default="star-fr-cloud-gov-06-16"
}

variable "apps_cert_name" {
    default="star-fr-cloud-gov-06-16"
}

variable "services_cidr_1" {}
variable "services_cidr_2" {}

variable "monitoring_elb_cert_name" {
  default = "star-fr-cloud-gov-06-16"
}

variable "logsearch_elb_cert_name" {
  default = "star-fr-cloud-gov-06-16"
}

variable "restricted_ingress_web_cidrs" {}

/* Variables for Diego Deployment */

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "diego_cidr_1" {}

variable "diego_cidr_2" {}



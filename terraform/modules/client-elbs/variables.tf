variable "star_18f_gov_cert_name" {}

variable "count" {}

variable "elb_subnets" {
  type = "list"
}

variable "elb_security_groups" {
  type = "list"
}

variable "stack_description" {}

variable "account_id" {}

variable "aws_partition" {}

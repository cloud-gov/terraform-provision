variable "stack_description" {}

variable "vpc_id" {}

variable "elb_subnets" {
  type = "list"
}

variable "elb_security_groups" {
  type = "list"
}

variable "elb_shibboleth_cert_id" {}

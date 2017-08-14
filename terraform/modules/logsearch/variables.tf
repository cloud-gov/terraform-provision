variable "aws_partition" {}
variable "account_id" {}
variable "stack_description" {}
variable "vpc_id" {}
variable "elb_subnets" {type = "list"}
variable "bosh_security_group" {}
variable "restricted_security_group" {}
variable "elb_cert_name" {}

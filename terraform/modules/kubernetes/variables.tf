variable "stack_description" {}
variable "aws_default_region" {}

variable "vpc_id" {}
variable "vpc_cidr" {}
variable "tooling_vpc_cidr" {}
variable "elb_subnets" {}
variable "target_bosh_security_group" {}
variable "target_monitoring_security_group" {}
variable "target_concourse_security_group" {}

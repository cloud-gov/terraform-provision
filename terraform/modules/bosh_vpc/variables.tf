variable "stack_description" {
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "public_cidr_1" {
  default = "10.0.100.0/24"
}

variable "public_cidr_2" {
  default = "10.0.101.0/24"
}

variable "private_cidr_1" {
  default = "10.0.1.0/24"
}

variable "private_cidr_2" {
  default = "10.0.2.0/24"
}

variable "restricted_ingress_web_cidrs" {
  type    = list(string)
  default = ["127.0.0.1/32", "192.168.0.1/24"]
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type    = list(string)
  default = []
}

variable "nat_gateway_instance_type" {
  default = "c3.2xlarge"
}

variable "monitoring_security_group_cidrs" {
  type    = list(string)
  default = []
}

variable "concourse_security_group_cidrs" {
  type    = list(string)
  default = []
}

variable "bosh_default_ssh_public_key" {

}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}

variable "cidr_blocks" {
  type    = list(string)
  default = []
}

variable "egress_traffic_through_inspection_vpc" {
  type        = bool
  default     = false
  description = "When true, egress traffic from the VPC is routed through the network firewall inspection VPC"
}

variable "transit_gateway_id" {
  type        = string
  default     = ""
  description = "The id of the transit gateway in the inspection VPC"
}

variable "tgw_cidr_blocks" {
  type    = list(string)
  default = ["10.100.1.0/28", "10.100.1.16/28"]
}

variable "remote_state_bucket" {
  type        = string
  description = "The remote terraform state bucket name used to fetch the state of the nfw_inspection_vpc module."
  default     = ""
}

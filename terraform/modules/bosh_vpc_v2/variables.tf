variable "stack_description" {
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-gov-west-1a", "us-gov-west-1b"]
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "public_cidrs" {
  type    = list(string)
  default = ["10.0.100.0/24", "10.0.101.0/24"]
}

variable "private_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
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

# variable "monitoring_security_group_cidrs" {
#   type    = list(string)
#   default = []
# }

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

variable "canonical_stemcell_share_account_id" {
  type = string
  description = "The account id owning the Canonical bucket where fips stemcells are published."
}
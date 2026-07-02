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


variable "create_network_firewall" {
  description = "Create and configure an AWS Network Firewall for ingress/egress inspection."
  type        = bool
  default     = false
}

variable "firewall_cidr_1" {
  description = "CIDR for the AZ1 firewall subnet (min /28). Used only when create_network_firewall is true."
  type        = string
  default     = "10.0.200.0/28"
}

variable "firewall_cidr_2" {
  description = "CIDR for the AZ2 firewall subnet (min /28)."
  type        = string
  default     = "10.0.201.0/28"
}

variable "nat_cidr_1" {
  description = "CIDR for the AZ1 dedicated NAT subnet (min /28). Used only when create_network_firewall is true."
  type        = string
  default     = "10.0.202.0/28"
}

variable "nat_cidr_2" {
  description = "CIDR for the AZ2 dedicated NAT subnet (min /28)."
  type        = string
  default     = "10.0.203.0/28"
}

variable "firewall_managed_rule_groups" {
  description = "List of managed (or custom) stateful rule groups to attach to the firewall policy."
  type = list(object({
    resource_arn             = string
    priority                 = number
    override_action_to_count = optional(bool, false)
  }))
  default = []
}

variable "firewall_rule_groups_count_only" {
  description = "Global override: when true, ALL managed rule groups run in count/alert-only mode (no drops)."
  type        = bool
  default     = false
}

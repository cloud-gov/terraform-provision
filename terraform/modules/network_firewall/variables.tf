variable "environment" {
  type        = string
  description = "The name of the environment the firewall is being installed in. Example: development"
}

variable "firewall_name" {
  type        = string
  description = "The name of the firewall. Do not use spaces as this value is used to construct other resource names. Example: cf-api"
}

variable "firewall_subnets" {
  type        = map(string)
  description = "A map of availabilty zone (key) to cidr block range subnet (value) where the firewall will be installed. Example: {\"us-gov-west-1a\" = \"192.168.1.0/24\" \"us-gov-west-1b\" = \"192.168.2.0/24\"}"
}

variable "home_nets" {
  type        = list(string)
  description = "The HOME_NET variable should include, in most scenarios, the IP address of the monitored interface and all the local networks in use. See: https://aws.amazon.com/about-aws/whats-new/2023/05/aws-network-firewall-suricata-home-net-variable-override/. Example: [\"192.168.0.0/16\"]"
}

variable "protected_subnet_cidr_blocks" {
  type        = list(string)
  description = "A list of cidr block subnets to protect with the network firewall. Example: [\"192.168.1.0/24\"]"
}

variable "region" {
  type        = string
  description = "The AWS region. Example: us-gov-west-1"
}

variable "rule_groups" {
  type        = list(string)
  description = "The list of AWS managed rule groups to enable on the firewall. See: https://docs.aws.amazon.com/network-firewall/latest/developerguide/nwfw-managed-rule-groups.html. Example: [\"AttackInfrastructureStrictOrder\",\"ThreatSignaturesDoSStrictOrder\",]"
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC in which to install the network firewall.  Example: vpc-8675309"
}

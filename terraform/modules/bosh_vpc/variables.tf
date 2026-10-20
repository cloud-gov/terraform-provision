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

/*
 * Network firewall inspection VPC
 *
 * With both flags below false (the default) this module behaves exactly as it
 * did before these variables existed: no transit gateway subnets, no
 * attachment, and private egress straight out of this VPC's own NAT gateways.
 * Nothing below is read.
 *
 * The two flags exist so the cutover can be staged.
 */

variable "attach_to_inspection_vpc" {
  type        = bool
  default     = false
  description = "When true, build the spoke side of the inspection VPC attachment -- transit gateway subnets, the VPC attachment, this spoke's TGW route table, and its routes and propagation -- without moving any traffic onto it. This is phase one of a staged cutover: it is safe to apply at any time and leaves the attachment idle, so the TGW path can be verified before egress is switched. Implied by egress_traffic_through_inspection_vpc, so a single-phase cutover remains possible by setting only that flag."
}

variable "egress_traffic_through_inspection_vpc" {
  type        = bool
  default     = false
  description = "When true, private-subnet egress leaves this VPC via the transit gateway published by the firewall-inspection-vpc stack instead of this VPC's own NAT gateways. Implies attach_to_inspection_vpc. This is the flag that moves traffic: expect established outbound TCP connections to reset, because the source address external services see changes from this VPC's NAT EIPs to the inspection VPC's. The NAT gateways and their EIPs are deliberately left in place so the switch is reversible without reallocating addresses."
}

variable "firewall_inspection_remote_state_bucket" {
  type        = string
  default     = ""
  description = "S3 bucket holding the firewall-inspection-vpc stack's Terraform state. Read only when the VPC is attached to the inspection VPC; the remote state data source is gated so stacks that have opted out do not need this set."
}

variable "firewall_inspection_remote_state_key" {
  type        = string
  default     = "firewall-inspection-vpc/terraform.tfstate"
  description = "State key for the firewall-inspection-vpc stack within remote_state_bucket. Overridable rather than hardcoded because the key is a property of the caller's backend layout, not of this module."
}

variable "tgw_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDRs for the two transit gateway attachment subnets, one per AZ, ordered [az1, az2]. Must be inside vpc_cidr and must not overlap any other subnet in this VPC. A /28 is sufficient. Required when either inspection flag is true -- enforced by a precondition in nfw_inspection.tf rather than here, since a variable validation cannot see another variable. The default is the empty list rather than a pair of CIDRs because vpc_cidr differs per environment: any concrete default would be a valid subnet in one environment and an invalid or colliding one in the next."

  validation {
    condition     = length(var.tgw_subnet_cidrs) == 0 || length(var.tgw_subnet_cidrs) == 2
    error_message = "tgw_subnet_cidrs must be empty (not attached to the inspection VPC) or contain exactly two entries, one per AZ."
  }

  validation {
    condition     = alltrue([for c in var.tgw_subnet_cidrs : can(cidrnetmask(c))])
    error_message = "Each entry in tgw_subnet_cidrs must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = length(distinct(var.tgw_subnet_cidrs)) == length(var.tgw_subnet_cidrs)
    error_message = "tgw_subnet_cidrs must not contain duplicate entries; the two AZ subnets cannot share a CIDR."
  }
}

variable "inspection_internal_cidrs" {
  type        = list(string)
  default     = []
  description = "Internal CIDRs reachable through the inspection VPC's transit gateway that the public subnets should route over the TGW rather than the internet gateway. This is what sends east-west traffic originating in a public subnet through the firewall. The public default route stays on the internet gateway so inbound internet traffic to public load balancers still has a return path, which is why these destinations have to be enumerated instead of covered by 0.0.0.0/0. Leave empty to route nothing from the public subnets over the TGW; private-subnet egress is unaffected either way. Read only when egress_traffic_through_inspection_vpc is true."

  validation {
    condition     = alltrue([for c in var.inspection_internal_cidrs : can(cidrnetmask(c))])
    error_message = "Each entry in inspection_internal_cidrs must be a valid IPv4 CIDR block. IPv6 is not supported: the public route table's ::/0 route stays on the internet gateway and IPv6 traffic is not inspected."
  }

  validation {
    condition     = !contains(var.inspection_internal_cidrs, "0.0.0.0/0")
    error_message = "inspection_internal_cidrs must not contain 0.0.0.0/0. The public route table keeps its default route on the internet gateway so inbound traffic retains a return path; a second 0.0.0.0/0 route in the same table is a duplicate destination and fails at apply."
  }

  validation {
    condition     = length(distinct(var.inspection_internal_cidrs)) == length(var.inspection_internal_cidrs)
    error_message = "inspection_internal_cidrs must not contain duplicate entries. Duplicates are silently collapsed when the list is turned into a set, so rejecting them here surfaces what is almost certainly a copy-paste error in the caller's configuration."
  }
}

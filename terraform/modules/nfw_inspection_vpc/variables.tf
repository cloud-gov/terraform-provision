variable "name_prefix" {
  description = "Prefix applied to all resource names."
  type        = string
  default     = "centralized-inspection"
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}


# Transit Gateway
variable "create_transit_gateway" {
  description = "Whether to create a new TGW. If false, provide existing_transit_gateway_id."
  type        = bool
  default     = true
}

variable "existing_transit_gateway_id" {
  description = "Existing TGW ID to use when create_transit_gateway = false."
  type        = string
  default     = null
}

variable "amazon_side_asn" {
  description = "ASN for a newly created TGW."
  type        = number
  default     = 64512
}


# Inspection VPC
variable "inspection_vpc_cidr" {
  description = "CIDR block for the new inspection VPC."
  type        = string
  default     = "10.100.0.0/16"
}

variable "availability_zones" {
  description = "AZs used for the inspection VPC (module is built for two AZs)."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "This module is designed for exactly two AZs."
  }
}

variable "firewall_subnet_cidrs" {
  description = "CIDRs for firewall endpoint subnets (one per AZ)."
  type        = list(string)
  default     = ["10.100.0.0/28", "10.100.0.16/28"]
}

variable "tgw_subnet_cidrs" {
  description = "CIDRs for TGW attachment subnets (one per AZ)."
  type        = list(string)
  default     = ["10.100.1.0/28", "10.100.1.16/28"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public/NAT subnets (one per AZ) used for egress to the internet."
  type        = list(string)
  default     = ["10.100.2.0/28", "10.100.2.16/28"]
}


# Existing (spoke) VPCs
variable "spoke_vpcs" {
  description = <<-EOT
    Map of existing spoke VPCs to attach and inspect.
    Key is a logical name. Each entry references existing resources.
  EOT
  type = map(object({
    vpc_id = string
    # Subnets (one per AZ) that TGW attachment ENIs will be placed in.
    tgw_attachment_subnet_ids = list(string)
    # Route table IDs in the spoke that must be updated to send traffic to the TGW.
    # Typically the private/workload route tables.
    route_table_ids = list(string)
    # CIDR(s) representing this spoke, used for return routes in the inspection VPC.
    spoke_cidrs = list(string)
    # If true, this spoke's default route (0.0.0.0/0) is pointed at the TGW for egress inspection.
    inspect_egress = optional(bool, true)
  }))
}


# Network Firewall

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
  default     = true
}

variable "delete_protection" {
  description = "Enable delete protection on the firewall."
  type        = bool
  default     = true
}

variable "logging_enabled" {
  description = "Enable firewall flow/alert logging to CloudWatch."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 90
}

variable "allowed_domains" {
  description = "Optional list of domains to allow for egress (used only when creating the default policy)."
  type        = list(string)
  default     = []
}

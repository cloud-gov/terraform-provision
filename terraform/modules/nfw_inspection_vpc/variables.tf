variable "name_prefix" {
  description = "Prefix applied to all resource names."
  type        = string
  default     = "nfw-inspection"
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

# Inspection VPC
variable "inspection_vpc_cidr" {
  description = "CIDR block for the new inspection VPC."
  type        = string
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
}

variable "tgw_subnet_cidrs" {
  description = "CIDRs for TGW attachment subnets (one per AZ)."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public/NAT subnets (one per AZ) used for egress to the internet."
  type        = list(string)
}

# Network Firewall

variable "firewall_managed_rule_groups" {
  description = "List of managed (or custom) stateful rule groups to attach to the firewall policy."
  type = list(object({
    resource_name            = string
    priority                 = number
    override_action_to_count = optional(bool, true)
  }))
  default = []
}

variable "firewall_rule_groups_count_only" {
  description = "Global override: when true, ALL managed rule groups run in count/alert-only mode (no drops)."
  type        = bool
}

variable "delete_protection" {
  description = "Enable delete protection on the firewall."
  type        = bool
}

variable "logging_enabled" {
  description = "Enable firewall flow/alert logging to CloudWatch."
  type        = bool
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

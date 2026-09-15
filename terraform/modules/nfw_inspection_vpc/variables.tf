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

  validation {
    condition     = length(var.firewall_subnet_cidrs) == 2
    error_message = "This module is designed for exactly two AZs."
  }
}

variable "tgw_subnet_cidrs" {
  description = "CIDRs for TGW attachment subnets (one per AZ)."
  type        = list(string)

  validation {
    condition     = length(var.tgw_subnet_cidrs) == 2
    error_message = "This module is designed for exactly two AZs."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public/NAT subnets (one per AZ) used for egress to the internet."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "This module is designed for exactly two AZs."
  }
}

variable "internal_cidrs" {
  description = "CIDR blocks considered internal, excluding the inspection VPC itself. Used for return routes from the inspection VPC back to the transit gateway, and combined with inspection_vpc_cidr to build the Suricata HOME_NET rule variable. Every CIDR is routed in every AZ; these are remote destinations reached via the TGW, so they have no AZ affinity."
  type        = list(string)
  default     = ["10.0.0.0/8"]

  validation {
    condition     = length(var.internal_cidrs) > 0
    error_message = "At least one internal CIDR is required."
  }

  validation {
    condition     = alltrue([for c in var.internal_cidrs : can(cidrnetmask(c))])
    error_message = "Each entry in internal_cidrs must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = !contains(var.internal_cidrs, "0.0.0.0/0")
    error_message = "internal_cidrs must not contain 0.0.0.0/0; the default route is managed separately by the egress routes."
  }

  validation {
    condition     = length(distinct(var.internal_cidrs)) == length(var.internal_cidrs)
    error_message = "internal_cidrs must not contain duplicate entries; duplicates produce a duplicate route-key collision when fanning routes out across AZs."
  }
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

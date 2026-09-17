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
    error_message = "availability_zones must contain exactly two AZs; this module is designed for two."
  }
}

variable "firewall_subnet_cidrs" {
  description = "CIDRs for firewall endpoint subnets (one per AZ)."
  type        = list(string)

  validation {
    condition     = length(var.firewall_subnet_cidrs) == 2
    error_message = "firewall_subnet_cidrs must contain exactly two entries, one per AZ."
  }

  validation {
    condition     = alltrue([for c in var.firewall_subnet_cidrs : can(cidrnetmask(c))])
    error_message = "Each entry in firewall_subnet_cidrs must be a valid IPv4 CIDR block."
  }
}

variable "tgw_subnet_cidrs" {
  description = "CIDRs for TGW attachment subnets (one per AZ)."
  type        = list(string)

  validation {
    condition     = length(var.tgw_subnet_cidrs) == 2
    error_message = "tgw_subnet_cidrs must contain exactly two entries, one per AZ."
  }

  validation {
    condition     = alltrue([for c in var.tgw_subnet_cidrs : can(cidrnetmask(c))])
    error_message = "Each entry in tgw_subnet_cidrs must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public/NAT subnets (one per AZ) used for egress to the internet."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "public_subnet_cidrs must contain exactly two entries, one per AZ."
  }

  validation {
    condition     = alltrue([for c in var.public_subnet_cidrs : can(cidrnetmask(c))])
    error_message = "Each entry in public_subnet_cidrs must be a valid IPv4 CIDR block."
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
  description = "Global override: when true, ALL managed rule groups run in count/alert-only mode (no drops). Mutually exclusive with firewall_rule_groups_enforce_all."
  type        = bool
  default     = true
}

variable "firewall_rule_groups_enforce_all" {
  description = "Global override: when true, ALL managed rule groups enforce (DROP), ignoring each group's override_action_to_count. This is the cutover switch for promoting the firewall from alert-only to enforcing; flip it per environment after reviewing ALERT logs. Mutually exclusive with firewall_rule_groups_count_only."
  type        = bool
  default     = false

  validation {
    condition     = !(var.firewall_rule_groups_enforce_all && var.firewall_rule_groups_count_only)
    error_message = "firewall_rule_groups_enforce_all and firewall_rule_groups_count_only are mutually exclusive; set at most one to true."
  }
}

variable "stateful_default_actions" {
  description = "Actions applied to packets matching no stateful rule. Empty (the default) leaves the AWS behavior of passing unmatched traffic, which is fail-open and intentional while the firewall runs in alert-only mode. Set to e.g. [\"aws:drop_established\", \"aws:alert_established\"] to fail closed. Requires STRICT_ORDER, which this module always sets."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for a in var.stateful_default_actions : contains([
        "aws:drop_strict",
        "aws:drop_established",
        "aws:alert_strict",
        "aws:alert_established",
      ], a)
    ])
    error_message = "Each entry in stateful_default_actions must be one of: aws:drop_strict, aws:drop_established, aws:alert_strict, aws:alert_established."
  }
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

variable "flow_logs_enabled" {
  description = "Enable VPC flow logs for the inspection VPC. These are distinct from the firewall's own FLOW logs: firewall logs only cover traffic reaching a firewall endpoint, while VPC flow logs cover every ENI in the VPC including the TGW attachment, NAT gateways, and firewall endpoints."
  type        = bool
  default     = true
}

variable "flow_logs_aggregation_interval" {
  description = "Maximum seconds a flow of packets is aggregated into one VPC flow log record. AWS accepts only 60 or 600. 60 gives finer incident reconstruction at roughly 10x the record volume."
  type        = number
  default     = 60

  validation {
    condition     = contains([60, 600], var.flow_logs_aggregation_interval)
    error_message = "flow_logs_aggregation_interval must be either 60 or 600 seconds."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

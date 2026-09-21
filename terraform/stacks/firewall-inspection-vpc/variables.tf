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
  default     = "10.100.0.0/16"
}

variable "availability_zones" {
  description = "AZs used for the inspection VPC (module is built for two AZs)."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "This module is designed for exactly two AZs."
  }

  default = ["us-gov-west-1a", "us-gov-west-1b"]
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

variable "internal_cidrs" {
  description = "CIDR blocks considered internal. Used for the Suricata HOME_NET rule variable and for return routes from the inspection VPC back to the transit gateway."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# Network Firewall

variable "firewall_managed_rule_groups" {
  description = "List of managed (or custom) stateful rule groups to attach to the firewall policy."
  type = list(object({
    resource_name            = string
    priority                 = number
    override_action_to_count = optional(bool, true)
  }))
  default = [{
    resource_name            = "AttackInfrastructureStrictOrder"
    priority                 = 1
    override_action_to_count = true
  }]
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
}

variable "stateful_default_actions" {
  description = "Actions applied to packets matching no stateful rule. Empty (the default) leaves the AWS behavior of passing unmatched traffic, which is fail-open and intentional while the firewall runs in alert-only mode. Set to e.g. [\"aws:drop_established\", \"aws:alert_established\"] to fail closed. Much larger blast radius than rule group enforcement -- treat as a separate change with its own baseline review."
  type        = list(string)
  default     = []
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
  description = "Maximum seconds a flow of packets is aggregated into one VPC flow log record. AWS accepts only 60 or 600 (validated in the module). 60 gives finer incident reconstruction at roughly 10x the record volume."
  type        = number
  default     = 60
}

variable "log_retention_days" {
  description = "CloudWatch retention, in days, for both the firewall log groups and the VPC flow log group. Must be a value CloudWatch Logs accepts (validated in the module); 0 means never expire. Defaults to 1096 (3 years), the repo-wide value chosen as the lowest option satisfying the M-21-31 requirement to retain network telemetry for 30 months. Lowering it below 913 days puts the platform out of compliance with that requirement."
  type        = number
  default     = 1096
}

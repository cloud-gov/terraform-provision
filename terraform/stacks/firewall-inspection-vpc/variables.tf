# Root-module inputs for ../../modules/nfw_inspection_vpc.
#
# Type declarations only. Descriptions, validation, and any defaults live in that
# module's variables.tf, which is the single source of truth.
#
# Nothing here has a default. Every value comes from the tfvars file or the
# pipeline's TF_VAR_* environment.

variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

# Inspection VPC

variable "inspection_vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "firewall_subnet_cidrs" {
  type = list(string)
}

variable "tgw_subnet_cidrs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "internal_cidrs" {
  type = list(string)
}

# Network Firewall

variable "firewall_managed_rule_groups" {
  type = list(object({
    resource_name            = string
    priority                 = number
    override_action_to_count = optional(bool, true)
  }))
}

variable "firewall_rule_groups_count_only" {
  type = bool
}

variable "firewall_rule_groups_enforce_all" {
  type = bool
}

variable "stateful_default_actions" {
  type = list(string)
}

variable "delete_protection" {
  type = bool
}

variable "logging_enabled" {
  type = bool
}

variable "flow_logs_enabled" {
  type = bool
}

variable "flow_logs_aggregation_interval" {
  type = number
}

variable "log_retention_days" {
  type = number
}

variable "prevent_ngw_eip_destroy" {
  type = bool
}

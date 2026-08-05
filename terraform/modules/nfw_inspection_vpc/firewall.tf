locals {
  # Map AZ -> firewall endpoint ID for route targeting.
  # The firewall creates one endpoint (VPCE) per firewall subnet/AZ.
  fw_endpoints = {
    for s in tolist(aws_networkfirewall_firewall.this.firewall_status[0].sync_states) :
    s.availability_zone => s.attachment[0].endpoint_id
  }

  # All spoke CIDRs flattened (used for return routes in the inspection VPC).
  # all_spoke_cidrs = distinct(flatten([for k, v in var.spoke_vpcs : v.spoke_cidrs]))

  firewall_managed_rule_groups = [
    for rg in var.firewall_managed_rule_groups : {
      resource_arn = rg.resource_arn
      priority     = rg.priority
      count_only   = var.firewall_rule_groups_count_only || rg.override_action_to_count
    }
  ]
}

resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.name_prefix}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    dynamic "stateful_rule_group_reference" {
      for_each = local.firewall_managed_rule_groups
      content {
        resource_arn = stateful_rule_group_reference.value.resource_arn
        priority     = stateful_rule_group_reference.value.priority

        dynamic "override" {
          for_each = stateful_rule_group_reference.value.count_only ? [1] : []
          content {
            action = "DROP_TO_ALERT" # Alert only
          }
        }
      }
    }
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-fw-policy" })
}

############################################
# The firewall itself (endpoints land in firewall subnets)
############################################
resource "aws_networkfirewall_firewall" "this" {
  name                = "${var.name_prefix}-fw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = aws_vpc.inspection.id
  delete_protection   = var.delete_protection

  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall
    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-fw" })
}

############################################
# Logging
############################################
resource "aws_cloudwatch_log_group" "flow" {
  count             = var.logging_enabled ? 1 : 0
  name              = "/aws/network-firewall/${var.name_prefix}/flow"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "alert" {
  count             = var.logging_enabled ? 1 : 0
  name              = "/aws/network-firewall/${var.name_prefix}/alert"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_networkfirewall_logging_configuration" "this" {
  count        = var.logging_enabled ? 1 : 0
  firewall_arn = aws_networkfirewall_firewall.this.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.flow[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.alert[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}

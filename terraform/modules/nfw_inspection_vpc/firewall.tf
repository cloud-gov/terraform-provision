locals {
  # Map AZ -> firewall endpoint ID for route targeting.
  # The firewall creates one endpoint (VPCE) per firewall subnet/AZ.
  fw_endpoints = {
    for s in tolist(aws_networkfirewall_firewall.firewall.firewall_status[0].sync_states) :
    s.availability_zone => s.attachment[0].endpoint_id
  }

  # Per-group enforcement decision. The two global flags are validated as
  # mutually exclusive, so at most one of these branches applies:
  #   enforce_all -> every group drops, regardless of its own setting
  #   count_only  -> every group alerts only
  #   neither     -> each group honors its own override_action_to_count
  firewall_managed_rule_groups = [
    for rg in var.firewall_managed_rule_groups : {
      resource_name = rg.resource_name
      priority      = rg.priority
      count_only = var.firewall_rule_groups_enforce_all ? false : (
        var.firewall_rule_groups_count_only || rg.override_action_to_count
      )
    }
  ]
}

resource "aws_networkfirewall_firewall_policy" "policy" {
  name = "${var.name_prefix}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    # Empty by default: unmatched traffic is passed. Fail-open is deliberate
    # while the firewall runs alert-only against existing VPCs. See the
    # stateful_default_actions variable and the README.
    stateful_default_actions = var.stateful_default_actions

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    dynamic "stateful_rule_group_reference" {
      for_each = local.firewall_managed_rule_groups
      content {
        priority     = stateful_rule_group_reference.value.priority
        resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${data.aws_region.current.region}:aws-managed:stateful-rulegroup/${stateful_rule_group_reference.value.resource_name}"

        dynamic "override" {
          for_each = stateful_rule_group_reference.value.count_only ? [1] : []
          content {
            action = "DROP_TO_ALERT" # Alert only
          }
        }
      }
    }
    policy_variables {
      rule_variables {
        key = "HOME_NET"
        ip_set {
          # The inspection VPC is part of the internal address space, so it must
          # be in HOME_NET regardless of what the caller passes. internal_cidrs
          # is scoped to remote spokes reached via the TGW and need not contain
          # it; leaving it out silently changes the meaning of every Suricata
          # rule keyed on $HOME_NET.
          definition = distinct(concat(var.internal_cidrs, [var.inspection_vpc_cidr]))
        }
      }
    }
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-firewall-policy" })
}

resource "aws_networkfirewall_firewall" "firewall" {
  name                = "${var.name_prefix}-fw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.policy.arn
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

resource "aws_networkfirewall_logging_configuration" "config" {
  count        = var.logging_enabled ? 1 : 0
  firewall_arn = aws_networkfirewall_firewall.firewall.arn

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

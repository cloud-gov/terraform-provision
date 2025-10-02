provider "aws" {
  use_fips_endpoint = true
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_availability_zone" "azs" {
  for_each = var.firewall_subnets
  name     = each.key
}

data "aws_subnet" "protected-subnets" {
  for_each   = toset(var.protected_subnet_cidr_blocks)
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = each.value
}

resource "aws_subnet" "firewall-subnets" {
  for_each          = var.firewall_subnets
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = {
    Name = var.firewall_name
  }
}

resource "aws_networkfirewall_firewall_policy" "aws-managed-stateful-rules" {
  name = var.firewall_name

  firewall_policy {
    policy_variables {
      rule_variables {
        key = "HOME_NET"
        ip_set {
          definition = var.home_nets
        }
      }
    }
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    dynamic "stateful_rule_group_reference" {
      for_each = var.rule_groups
      content {
        priority     = index(var.rule_groups, stateful_rule_group_reference.value) + 1
        resource_arn = "arn:aws-us-gov:network-firewall:${var.region}:aws-managed:stateful-rulegroup/${stateful_rule_group_reference.value}"
      }
    }
  }
}

resource "aws_networkfirewall_firewall" "network-firewall" {
  name                   = var.firewall_name
  firewall_policy_arn    = aws_networkfirewall_firewall_policy.aws-managed-stateful-rules.arn
  vpc_id                 = data.aws_vpc.vpc.id
  enabled_analysis_types = ["TLS_SNI", "HTTP_HOST"]
  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall-subnets
    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  timeouts {
    create = "40m"
    update = "50m"
    delete = "1h"
  }
}

resource "aws_networkfirewall_vpc_endpoint_association" "association" {
  for_each     = data.aws_subnet.protected-subnets
  firewall_arn = aws_networkfirewall_firewall.network-firewall.arn
  vpc_id       = data.aws_vpc.vpc.id

  subnet_mapping {
    subnet_id = each.value.id
  }
}

# Create CloudWatch log group
resource "aws_cloudwatch_log_group" "network_firewall_cloudwatch_log_group" {
  name = "${var.environment}-${var.firewall_name}-firewall-log-group"
  # Lowest allowed value that fulfills M-21-31 reqs of storing for 30 months
  retention_in_days = 1096
}

# # Create IAM role for sending flow logs
# resource "aws_iam_role" "flow_log_role" {
#   name               = "${var.environment}-${var.firewall_name}-firewall-log-role"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "vpc-flow-logs.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF

# }

# resource "aws_iam_role_policy" "flow_log_policy" {
#   name   = "${var.stack_description}-flow-log-policy"
#   role   = aws_iam_role.flow_log_role.id
#   policy = <<EOF
# {
#     "Version":"2012-10-17",		 	 	 
#     "Statement": [
#         {
#             "Action": [
#                 "logs:CreateLogDelivery",
#                 "logs:GetLogDelivery",
#                 "logs:UpdateLogDelivery",
#                 "logs:DeleteLogDelivery",
#                 "logs:ListLogDeliveries"
#             ],
#             "Resource": [
#                 "*"
#             ],
#             "Effect": "Allow",
#             "Sid": "FirewallLogging"
#         },
#         {
#             "Sid": "FirewallLoggingCWL",
#             "Action": [
#                 "logs:PutResourcePolicy",
#                 "logs:DescribeResourcePolicies",
#                 "logs:DescribeLogGroups"
#             ],
#             "Resource": [
#             "arn:aws:logs:us-east-1:123456789012:log-group:log-group-name"
#             ],
#             "Effect": "Allow"
#         }
#     ]
# }
# EOF

# }

# resource "aws_flow_log" "main_vpc_flow_log" {
#   log_destination = aws_cloudwatch_log_group.main_vpc_flow_log_cloudwatch_log_group.arn
#   iam_role_arn    = aws_iam_role.flow_log_role.arn
#   vpc_id          = aws_vpc.main_vpc.id
#   traffic_type    = "ALL"
# }

resource "aws_networkfirewall_logging_configuration" "logging" {
  firewall_arn = aws_networkfirewall_firewall.network-firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall_cloudwatch_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}

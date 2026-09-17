# VPC flow logs for the inspection VPC.
#
# Network Firewall FLOW/ALERT logs only cover traffic that actually reaches a
# firewall endpoint. They say nothing about the TGW attachment, NAT gateway, or
# IGW hops, so traffic that bypasses inspection -- whether by misrouting or by
# design -- leaves no record. This VPC is the single egress chokepoint for every
# attached spoke, which makes that gap the most consequential one in the
# platform.
#
# Flow logs capture every ENI in the VPC, including the TGW attachment, NAT
# gateway, and firewall endpoint interfaces, giving an inspection-independent
# record of what actually crossed the boundary.

resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.flow_logs_enabled ? 1 : 0
  name              = "/aws/vpc-flow-log/${var.name_prefix}"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Name = "${var.name_prefix}-vpc-flow-log" })
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  count = var.flow_logs_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    # Confused-deputy protection: the flow log service may only assume this role
    # on behalf of this account, for a flow log in this account.
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"]
    }
  }
}

data "aws_iam_policy_document" "flow_logs" {
  count = var.flow_logs_enabled ? 1 : 0

  # Scoped to this module's log group rather than "*". The stream-level ARN
  # (:log-stream:*) is required because the service creates one stream per ENI.
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      aws_cloudwatch_log_group.flow_logs[0].arn,
      "${aws_cloudwatch_log_group.flow_logs[0].arn}:log-stream:*",
    ]
  }
}

resource "aws_iam_role" "flow_logs" {
  count              = var.flow_logs_enabled ? 1 : 0
  name               = "${var.name_prefix}-vpc-flow-log-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role[0].json
  tags               = merge(var.tags, { Name = "${var.name_prefix}-vpc-flow-log-role" })
}

resource "aws_iam_role_policy" "flow_logs" {
  count  = var.flow_logs_enabled ? 1 : 0
  name   = "${var.name_prefix}-vpc-flow-log-policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs[0].json
}

resource "aws_flow_log" "inspection" {
  count                = var.flow_logs_enabled ? 1 : 0
  vpc_id               = aws_vpc.inspection.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn         = aws_iam_role.flow_logs[0].arn

  # 60s rather than the 600s default: this is the platform egress chokepoint, so
  # aggregation granularity bounds how precisely an incident can be
  # reconstructed. Also the value AWS requires if TGW-level flow logs are added
  # later. Costs roughly 10x the record volume of 600s.
  max_aggregation_interval = var.flow_logs_aggregation_interval

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc-flow-log" })
}

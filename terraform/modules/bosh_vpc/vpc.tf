/*
 * Variables required:
 *  stack_description
 *  vpc_cidr
 */

resource "aws_vpc" "main_vpc" {
  cidr_block                       = var.vpc_cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = var.stack_description
  }
}

# Create CloudWatch log group
resource "aws_cloudwatch_log_group" "main_vpc_flow_log_cloudwatch_log_group" {
  name = "${var.stack_description}-flow-log-group"
  # Lowest allowed value that fulfills M-21-31 reqs of storing for 30 months
  retention_in_days = 1096
}

# Create IAM role for sending flow logs
resource "aws_iam_role" "flow_log_role" {
  name               = "${var.stack_description}-flow-log-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "flow_log_policy" {
  name   = "${var.stack_description}-flow-log-policy"
  role   = aws_iam_role.flow_log_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_flow_log" "main_vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.main_vpc_flow_log_cloudwatch_log_group.arn
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  vpc_id          = aws_vpc.main_vpc.id
  traffic_type    = "ALL"
}

data "aws_network_acls" "default" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_network_acl_rule" "deny_rule_ingress_rules" {
  count = length(data.aws_network_acls.default.ids) * length(var.cidr_blocks)

  rule_number    = 201 + count.index
  network_acl_id = data.aws_network_acls.default.ids[count.index / length(var.cidr_blocks)]
  rule_action    = "deny"
  protocol       = "-1"
  cidr_block     = var.cidr_blocks[count.index % length(var.cidr_blocks)]
  from_port      = 0
  to_port        = 0
  egress         = false
}

resource "aws_network_acl_rule" "deny_rule_egress_rules" {
  count = length(data.aws_network_acls.default.ids) * length(var.cidr_blocks)

  rule_number    = 201 + count.index
  network_acl_id = data.aws_network_acls.default.ids[count.index / length(var.cidr_blocks)]
  rule_action    = "deny"
  protocol       = "-1"
  cidr_block     = var.cidr_blocks[count.index % length(var.cidr_blocks)]
  from_port      = 0
  to_port        = 0
  egress         = true
}

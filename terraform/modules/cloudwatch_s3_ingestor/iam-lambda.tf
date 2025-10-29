# Lambda IAM resources
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  for_each = toset(var.environments)
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  for_each           = toset(var.environments)
  name               = "${var.name_prefix}-${each.key}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy[each.key].json
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "aws_iam_role" "cloudwatch_lambda_role" {
  for_each           = toset(var.environments)
  name               = "cloudwatch-${var.name_prefix}-${each.key}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy[each.key].json
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

data "aws_iam_policy_document" "lambda_logs_policy" {
  for_each = toset(var.environments)

  statement {
    actions = [
      "logs:PutSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeSubscriptionFilters"
    ]
    effect = "Allow"
    resources = [
      "arn:${var.aws_partition}:logs:${var.aws_region}:${var.account_id}:log-group:/aws/rds/instance/cg-aws-broker-${local.prefixes[each.key]}*"
    ]
  }

  statement {
    actions = [
      "iam:PassRole"
    ]
    effect = "Allow"
    resources = [
      "arn:${var.aws_partition}:iam::${var.account_id}:role/${aws_iam_role.cloudwatch_role[each.key].name}"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_logs_policy" {
  for_each = toset(var.environments)
  name     = "${var.name_prefix}-${each.key}-lambda-logs-policy"
  role     = aws_iam_role.cloudwatch_lambda_role[each.key].id
  policy   = data.aws_iam_policy_document.lambda_logs_policy[each.key].json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  for_each   = toset(var.environments)
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_lambda_basic_execution" {
  for_each   = toset(var.environments)
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.cloudwatch_lambda_role[each.key].name
}

data "aws_iam_policy_document" "lambda_tag_policy" {
  for_each = toset(var.environments)
  statement {
    actions = [
      "rds:ListTagsForResource",
      "rds:DescribeDBInstances"
    ]
    effect = "Allow"
    resources = [
      "arn:${var.aws_partition}:rds:${var.aws_region}:${var.account_id}:db:cg-aws-broker-${local.prefixes[each.key]}*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_tag_policy" {
  for_each = toset(var.environments)
  name     = "${var.name_prefix}-${each.key}-lambda-tag-policy"
  role     = aws_iam_role.lambda_role[each.key].id
  policy   = data.aws_iam_policy_document.lambda_tag_policy[each.key].json
}

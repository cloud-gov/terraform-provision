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
      "arn:${var.aws_partition}:rds:${var.aws_region}:${var.account_id}:db:cg-aws-broker-*"
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
      "arn:${var.aws_partition}:rds:${var.aws_region}:${var.account_id}:db:cg-aws-broker-*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_tag_policy" {
  for_each = toset(var.environments)
  name     = "${var.name_prefix}-${each.key}-lambda-tag-policy"
  role     = aws_iam_role.lambda_role[each.key].id
  policy   = data.aws_iam_policy_document.lambda_tag_policy[each.key].json
}

data "aws_iam_policy_document" "firehose_assume_role_policy" {
  for_each = toset(var.environments)
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  for_each           = toset(var.environments)
  name               = "${var.name_prefix}-${each.key}-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role_policy[each.key].json
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

data "aws_iam_policy_document" "firehose_policy" {
  for_each = toset(var.environments)
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.opensearch_cloudwatch_buckets[each.key].arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [aws_lambda_function.transform[each.key].arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = ["arn:${var.aws_partition}:logs:${var.aws_region}:${var.account_id}:log-group:/aws/lambda/${var.name_prefix}-*"]
  }
}

resource "aws_iam_role_policy" "firehose_policy" {
  for_each = toset(var.environments)
  name     = "${var.name_prefix}-${each.key}-firehose-policy"
  role     = aws_iam_role.firehose_role[each.key].id
  policy   = data.aws_iam_policy_document.firehose_policy[each.key].json
}

data "aws_iam_policy_document" "cloudwatch_assume_role_policy" {
  for_each = toset(var.environments)
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  for_each           = toset(var.environments)
  name               = "${var.name_prefix}-${each.key}-cloud-to-fire-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role_policy[each.key].json
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

data "aws_iam_policy_document" "cloudwatch_policy" {
  for_each = toset(var.environments)
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      "arn:${var.aws_partition}:firehose:${var.aws_region}:${var.account_id}:deliverystream/${aws_kinesis_firehose_delivery_stream.cloudwatch_stream[each.key].name}"
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  for_each = toset(var.environments)
  name     = "${var.name_prefix}-${each.key}-cloudwatch-to-firehose-policy"
  role     = aws_iam_role.cloudwatch_role[each.key].id
  policy   = data.aws_iam_policy_document.cloudwatch_policy[each.key].json
}

resource "aws_iam_role" "eventbridge_lambda_role" {
  for_each = toset(var.environments)
  name = "${var.name_prefix}-${each.key}-eventbridge-lambda-role" 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_lambda_policy" {
  for_each = toset(var.environments)
  name        = "${var.name_prefix}-${each.key}-eventbridge-lambda-policy"
  description = "Policy for EventBridge to invoke Lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = aws_lambda_function.cloudwatch_filter.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_lambda_attachment" {
  role       = aws_iam_role.eventbridge_lambda_role.name
  policy_arn = aws_iam_policy.eventbridge_lambda_policy.arn
}
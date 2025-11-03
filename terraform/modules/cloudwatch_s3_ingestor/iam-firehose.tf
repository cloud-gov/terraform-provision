# Firehose IAM resources
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
    resources = ["${aws_lambda_function.transform[each.key].arn}/*"]
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
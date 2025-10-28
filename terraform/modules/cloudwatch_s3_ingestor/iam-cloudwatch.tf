# CloudWatch IAM resources
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
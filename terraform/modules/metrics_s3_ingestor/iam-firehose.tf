resource "aws_iam_role" "firehose_role" {
  for_each = toset(var.environments)
  name     = "${var.name_prefix}-${each.key}-firehose-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "aws_iam_role_policy" "firehose_policy" {
  for_each = toset(var.environments)
  name     = "${var.name_prefix}-${each.key}-firehose-policy"
  role     = aws_iam_role.firehose_role[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.opensearch_metric_buckets[each.key].arn}",
          "${aws_s3_bucket.opensearch_metric_buckets[each.key].arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = [aws_lambda_function.transform[each.key].arn,
          "${aws_lambda_function.transform[each.key].arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = ["arn:${var.aws_partition}:logs:${var.aws_region}:${var.account_id}:log-group:/aws/lambda/${var.name_prefix}-*",
          "arn:${var.aws_partition}:logs:${var.aws_region}:${var.account_id}:log-group:/aws/kinesisfirehose/${var.name_prefix}-${each.key}-delivery-stream:*"
        ]
      }
    ]
  })
}
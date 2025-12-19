resource "aws_iam_role" "metric_stream_role" {
  for_each = toset(var.environments)

  name = "${var.name_prefix}-${each.key}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "streams.metrics.cloudwatch.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "aws_iam_role_policy" "metric_stream_policy" {
  for_each = toset(var.environments)

  name = "${var.name_prefix}-${each.key}-metric-stream-policy"
  role = aws_iam_role.metric_stream_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = [
          aws_kinesis_firehose_delivery_stream.metric_stream[each.key].arn
        ]
      }
    ]
  })
}

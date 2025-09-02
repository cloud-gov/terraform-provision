resource "aws_iam_role" "lambda_role" {
  for_each = toset(var.environments)

  name = "${var.name_prefix}-${each.key}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Environment = each.key
  })

}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  for_each = toset(var.environments)

  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role[each.key].name
}

resource "aws_iam_role" "firehose_role" {
  for_each = toset(var.environments)

  name = "${var.name_prefix}-${each.key}-firehose-role"

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

  name = "${var.name_prefix}-${each.key}-firehose-policy"
  role = aws_iam_role.firehose_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.opensearch_metric_buckets[each.key].arn,
          "${aws_s3_bucket.opensearch_metric_buckets[each.key].arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = aws_lambda_function.transform[each.key].arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws-us-gov:logs:*:*:*"
      }
    ]
  })
}

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

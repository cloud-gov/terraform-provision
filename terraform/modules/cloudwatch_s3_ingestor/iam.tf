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

  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role[each.key].name
}

resource "aws_iam_role_policy" "lambda_tag_policy" {
  for_each = toset(var.environments)

  name = "${var.name_prefix}-${each.key}-lambda-tag-policy"
  role = aws_iam_role.lambda_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "rds:ListTagsForResource",
          "rds:DescribeDBInstances"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:${var.aws_partition}:rds:${var.aws_region}:${var.account_id}:db:cg-aws-broker-*"
        ]
      }
    ]
  })
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
          "${aws_s3_bucket.opensearch_cloudwatch_buckets[each.key].arn}/*"
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
        Resource = ["arn:${var.aws_partition}:logs:${var.aws_region}:${var.account_id}:log-group:/aws/lambda/${var.name_prefix}-*"]
      }
    ]
  })
}

resource "aws_iam_role" "cloudwatch_role" {
  for_each = toset(var.environments)

  name = "${var.name_prefix}-${each.key}-cloud-to-fire-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  for_each = toset(var.environments)

  name = "${var.name_prefix}-${each.key}-cloudwatch-to-firehose-policy"
  role = aws_iam_role.cloudwatch_role[each.key].id

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
          "arn:${var.aws_partition}:firehose:${var.aws_region}:${var.account_id}:deliverystream/${aws_kinesis_firehose_delivery_stream.cloudwatch_stream[each.key].name}"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "logs_opensearch_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logs-opensearch-*/*"
    ]
  }

  statement {
    actions = [
      "es:ListDomainNames",
      "es:ListTags"
    ]

    resources = [
      "arn:${var.aws_partition}:es:${var.aws_default_region}:${var.account_id}:domain/*"
    ]
  }

  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents",
      "logs:ListTagsLogGroup"
    ]

    resources = [
      "arn:${var.aws_partition}:logs:${var.aws_default_region}:${var.account_id}:*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:${var.aws_partition}:logs:${var.aws_default_region}:${var.account_id}:log-group:logs-opensearch-*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logsearch-*/*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logsearch-*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logs-opensearch-*/*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logs-opensearch-*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.logs_opensearch_policy.json
}

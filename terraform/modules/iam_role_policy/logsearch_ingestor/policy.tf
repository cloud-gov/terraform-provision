data "aws_iam_policy_document" "logsearch_ingestor_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logsearch-*/*"
    ]
  }

  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
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
      "arn:${var.aws_partition}:logs:${var.aws_default_region}:${var.account_id}:log-group:logsearch-*"
    ]
  }    
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.logsearch_ingestor_policy.json
}

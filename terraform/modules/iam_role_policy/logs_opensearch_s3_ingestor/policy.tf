data "aws_iam_policy_document" "logs_opensearch_s3_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logs-opensearch-*/*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.logs_opensearch_s3_policy.json
}

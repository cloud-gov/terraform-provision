data "aws_iam_policy_document" "logs_concourse_s3_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logs-concourse-*/*"
    ]
  }
  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::logs-concourse-*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.logs_concourse_s3_policy.json
}

data "aws_iam_policy_document" "bosh_compilation_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.bucket_name}",
      "arn:${var.aws_partition}:s3:::${var.bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.bosh_compilation_policy.json
}

data "aws_iam_policy_document" "blobstore_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
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
  policy = data.aws_iam_policy_document.blobstore_policy.json
}

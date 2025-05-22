data "aws_iam_policy_document" "s3_broker_task_policy" {
  statement {
    actions = [
      "s3:ListAllMyBucket",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.bucket_prefix}-*",
      "arn:${var.aws_partition}:s3:::${var.bucket_prefix}-*/*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.s3_broker_task_policy.json
}

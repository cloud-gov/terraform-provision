data "aws_iam_policy_document" "s3_broker_task_policy" {
  statement {
    actions = [
      "s3:PutBucketTagging",
      "s3:GetBucketTagging"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.bucket_prefix}-*",
      "arn:${var.aws_partition}:s3:::${var.bucket_prefix}-*/*"
    ]
  }
  statement {
    actions = [
      "s3:ListAllMyBuckets"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::*",
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.s3_broker_task_policy.json
}

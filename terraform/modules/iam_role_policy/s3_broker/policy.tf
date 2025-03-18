data "aws_iam_policy_document" "s3_broker_policy" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.bucket_prefix}-*",
      "arn:${var.aws_partition}:s3:::${var.bucket_prefix}-*/*"
    ]
  }

  statement {
    actions = [
      "iam:GetUser",
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:ListAccessKeys",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:ListAttachedUserPolicies",
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy",
      "iam:TagUser",
      "iam:UntagUser",
      "iam:TagPolicy",
      "iam:UntagPolicy"
    ]

    resources = [
      "arn:${var.aws_partition}:iam::${var.account_id}:user${var.iam_path}*",
      "arn:${var.aws_partition}:iam::${var.account_id}:policy${var.iam_path}",
      "arn:${var.aws_partition}:iam::${var.account_id}:policy${var.iam_path}*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.s3_broker_policy.json
}

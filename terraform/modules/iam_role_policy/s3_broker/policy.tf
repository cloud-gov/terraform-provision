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
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
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

  statement {
    actions = [
      "iam:ListUsers"
    ]

    # Resource constraint cannot be used with ListUsers
    # see https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsidentityandaccessmanagementiam.html#awsidentityandaccessmanagementiam-user
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies"
    ]

    resources = [
      "arn:${var.aws_partition}:iam::${var.account_id}:user/*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.s3_broker_policy.json
}

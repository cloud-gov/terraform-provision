// Originally from https://github.com/GSA-TTS/datagov-brokerpak-smtp/blob/main/permission-policies.tf
locals {
  this_aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
locals {
  govcloud = data.aws_partition.current.partition == "aws-us-gov"
}

data "aws_iam_policy_document" "brokerpak_smtp_govcloud" {
  statement {
    effect    = "Allow"
    actions   = ["ses:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:GetUser",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetUserPolicy",
      "iam:PutUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy",
      "iam:List*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:SetTopicAttributes",
      "sns:GetTopicAttributes",
      "sns:ListTagsForResource",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:GetSubscriptionAttributes"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "brokerpak_smtp" {
  count       = local.govcloud ? 1 : 0
  name        = "${var.stack_description}-brokerpak-smtp"
  description = "SMTP broker policy (covers SES, IAM, and supplementary Route53)"
  policy      = data.aws_iam_policy_document.brokerpak_smtp_govcloud.json
}

resource "aws_iam_user" "iam_user" {
  name = "${var.stack_description}-csb"
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

locals {
  govcloud_policies = [
    aws_iam_policy.brokerpak_smtp.arn
  ]
  commercial_policies = [
    // Route53 manager: for aws_route53_record, aws_route53_zone
    "arn:aws-us-gov:iam::aws:policy/AmazonRoute53FullAccess",
  ]
}

resource "aws_iam_user_policy_attachment" "csb_policies" {
  for_each = toset(local.govcloud ? local.govcloud_policies : local.commercial_policies)

  user       = aws_iam_user.iam_user.name
  policy_arn = each.key
}

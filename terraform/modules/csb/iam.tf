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

data "aws_iam_policy_document" "brokerpak_smtp_commercial" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZones"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "brokerpak_smtp" {
  name        = "${var.stack_description}-brokerpak-smtp"
  description = "Cloud Service Broker SMTP brokerpak policy"
  policy      = local.govcloud ? data.aws_iam_policy_document.brokerpak_smtp_govcloud.json : data.aws_iam_policy_document.brokerpak_smtp_commercial.json
}

resource "aws_iam_user" "iam_user" {
  name = "${var.stack_description}-csb"
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

locals {
  // Attribute aws_iam_policy.brokerpak_smtp.arn is not determined until apply, so it cannot be
  // referenced in for_each below. Build the ARN here instead.
  brokerpak_smtp_arn = "arn:aws-us-gov:iam::${local.this_aws_account_id}:policy/${aws_iam_policy.brokerpak_smtp.name}"
}

resource "aws_iam_user_policy_attachment" "csb_policies" {
  for_each = toset(local.govcloud ?
    // GovCloud policies
    [
      brokerpak_smtp_arn,
      aws_iam_policy.brokerpak_smtp.arn
    ] :
    // Commercial policies
    [
      brokerpak_smtp_arn,
      "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    ]
  )

  user       = aws_iam_user.iam_user.name
  policy_arn = each.key
}

// See also the companion user in Commercial (../commercial/csb.tf)
// Originally from https://github.com/GSA-TTS/datagov-brokerpak-smtp/blob/main/permission-policies.tf


data "aws_iam_policy_document" "brokerpak_aws_ses_govcloud" {
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

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricAlarm",
    ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "brokerpak_aws_ses" {
  name        = "${var.stack_description}-csb-brokerpak-aws-ses"
  description = "Cloud Service Broker policy for the 'aws-ses' brokerpak."
  policy      = data.aws_iam_policy_document.brokerpak_aws_ses_govcloud.json
}

resource "aws_iam_user" "csb" {
  name = "${var.stack_description}-csb"
}

resource "aws_iam_access_key" "csb" {
  user = aws_iam_user.csb.name
}

// Values required for policy attachment
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
locals {
  this_aws_account_id = data.aws_caller_identity.current.account_id
  // Attribute aws_iam_policy.brokerpak_aws_ses.arn is not determined until apply, so it cannot be
  // referenced in for_each below. Build the ARN here instead.
  brokerpak_aws_ses_arn = "arn:${data.aws_partition.current.partition}:iam::${local.this_aws_account_id}:policy/${aws_iam_policy.brokerpak_aws_ses.name}"
}

resource "aws_iam_user_policy_attachment" "csb_policies" {
  for_each = toset([
    # Each brokerpak will use a separate policy so it is clear which permissions they individually require.
    local.brokerpak_aws_ses_arn
  ])

  user       = aws_iam_user.csb.name
  policy_arn = each.key
}

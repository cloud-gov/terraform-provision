// See also the companion user in Commercial (../commercial/csb.tf)
// Originally from https://github.com/GSA-TTS/datagov-brokerpak-smtp/blob/main/permission-policies.tf

// Values required for policy attachment
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  this_aws_account_id = data.aws_caller_identity.current.account_id
  // Attribute aws_iam_policy.brokerpak_aws_ses.arn is not determined until apply, so it cannot be
  // referenced in for_each below. Build the ARN here instead.
  brokerpak_aws_ses_arn = "arn:${data.aws_partition.current.partition}:iam::${local.this_aws_account_id}:policy/${aws_iam_policy.brokerpak_aws_ses.name}"
  resource_prefix       = "csb-aws-ses*"
}

data "aws_iam_policy_document" "brokerpak_aws_ses_govcloud" {
  statement {
    effect = "Allow"
    actions = [
      "ses:CreateEmailIdentity",
      "ses:PutEmailIdentityMailFromAttributes",
      "ses:GetEmailIdentity",
      "ses:DeleteEmailIdentity",
      "ses:TagResource"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:ses:${data.aws_region.current.region}:${local.this_aws_account_id}:identity/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ses:DeleteConfigurationSet",
      "ses:GetConfigurationSet",
      "ses:CreateConfigurationSet",
      "ses:CreateConfigurationSetEventDestination",
      "ses:GetConfigurationSetEventDestinations",
      "ses:DeleteConfigurationSetEventDestination",
      "ses:UpdateConfigurationSetEventDestination",
      "ses:TagResource"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:ses:${data.aws_region.current.region}:${local.this_aws_account_id}:configuration-set/${local.resource_prefix}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      # "iam:List*",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:iam::${local.this_aws_account_id}:policy/${local.resource_prefix}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:GetUser",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:GetUserPolicy",
      "iam:PutUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUserTags",
      "iam:TagUser"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:iam::${local.this_aws_account_id}:user/cf/${local.resource_prefix}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:SetTopicAttributes",
      "sns:GetTopicAttributes",
      "sns:ListTagsForResource",
      "sns:Subscribe"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:sns:${data.aws_region.current.region}:${local.this_aws_account_id}:${local.resource_prefix}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Unsubscribe",
      "sns:GetSubscriptionAttributes"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:SetAlarmState",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:cloudwatch:${data.aws_region.current.region}:${local.this_aws_account_id}:alarm:${local.resource_prefix}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:CreateKey",
      "kms:ListAliases"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:DisableKey",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.region}:${local.this_aws_account_id}:key/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:DeleteAlias"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.region}:${local.this_aws_account_id}:alias/${local.resource_prefix}"]
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

resource "aws_iam_access_key" "csb_v2" {
  user = aws_iam_user.csb.name
}

resource "aws_iam_user_policy_attachment" "csb_policies" {
  for_each = toset([
    # Each brokerpak will use a separate policy so it is clear which permissions they individually require.
    local.brokerpak_aws_ses_arn
  ])

  user       = aws_iam_user.csb.name
  policy_arn = each.key
}

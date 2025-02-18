// Originally from https://github.com/GSA-TTS/datagov-brokerpak-smtp/blob/main/permission-policies.tf
locals {
  this_aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "concourse_csb" {
  statement {
    effect = "Allow"
    actions = [
      "sns:GetSubscriptionAttributes",
      "sns:SetSubscriptionAttributes",
      "sns:Subscribe",
      "sns:Unsubscribe",
    ]
    resources = [var.sns_platform_notification_topic_arn]
  }
}

resource "aws_iam_policy" "concourse_csb" {
  name        = "${var.stack_description}-concourse-csb"
  description = "Used by the Concourse pipeline `csb`, which uses Terraform to deploy the CSB and CSB Helper. The pipeline manages a subscription to the platform notifications topic on behalf of the CSB Helper."
  policy      = data.aws_iam_policy_document.concourse_csb.json
}

resource "aws_iam_user" "concourse_csb" {
  name = "${var.stack_description}-concourse-csb"
}

resource "aws_iam_user_policy_attachment" "concourse_csb" {
  user       = aws_iam_user.concourse_csb.name
  policy_arn = aws_iam_policy.concourse_csb.arn
}

resource "aws_iam_access_key" "concourse_csb" {
  user = aws_iam_user.concourse_csb.name
}

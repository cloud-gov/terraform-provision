// Originally from https://github.com/GSA-TTS/datagov-brokerpak-smtp/blob/main/permission-policies.tf
locals {
  this_aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "brokerpak_smtp" {
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
    effect    = "Allow"
    actions   = ["route53:ListHostedZones"]
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
  name        = "${var.stack_description}-brokerpak-smtp"
  description = "SMTP broker policy (covers SES, IAM, and supplementary Route53)"
  policy      = data.aws_iam_policy_document.brokerpak_smtp.json
}

resource "aws_iam_user" "iam_user" {
  name = "${var.stack_description}-csb"
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy_attachment" "csb_policies" {
  for_each = toset([
    // ACM manager: for aws_acm_certificate, aws_acm_certificate_validation
    "arn:aws-us-gov:iam::aws:policy/AWSCertificateManagerFullAccess",

    // Route53 manager: for aws_route53_record, aws_route53_zone
    "arn:aws-us-gov:iam::aws:policy/AmazonRoute53FullAccess",

    // SMTP brokerpak policy defined above
    "arn:aws-us-gov:iam::${local.this_aws_account_id}:policy/${aws_iam_policy.brokerpak_smtp.name}",
  ])

  user       = aws_iam_user.iam_user.name
  policy_arn = each.key
}

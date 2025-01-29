data "aws_iam_policy_document" "concourse_csb" {
  count = local.govcloud ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:GetSubscriptionAttributes"
    ]
    resources = [var.sns_platform_notification_topic_arn]
  }
}

resource "aws_iam_policy" "concourse_csb" {
  count = local.govcloud ? 1 : 0

  name        = "${var.stack_description}-concourse-csb"
  description = "Used by the Concourse pipeline `csb`, which uses Terraform to deploy the CSB and CSB Helper. The pipeline manages a subscription to the platform notifications topic on behalf of the CSB Helper."
  policy      = one(data.aws_iam_policy_document.concourse_csb[*].json)
}

resource "aws_iam_user" "concourse_csb" {
  count = local.govcloud ? 1 : 0

  name = "${var.stack_description}-concourse-csb"
}

resource "aws_iam_user_policy_attachment" "concourse_csb" {
  count = local.govcloud ? 1 : 0

  user       = aws_iam_user.concourse_csb
  policy_arn = one(aws_iam_policy.concourse_csb[*].arn)
}

resource "aws_iam_access_key" "concourse_csb_access_key" {
  count = local.govcloud ? 1 : 0

  user = one(aws_iam_user.concourse_csb[*].name)
}

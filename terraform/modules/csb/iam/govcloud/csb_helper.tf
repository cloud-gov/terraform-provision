data "aws_iam_policy_document" "csb_helper" {
  statement {
    effect    = "Allow"
    actions   = ["ses:UpdateConfigurationSetSendingEnabled"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:GetSubscriptionAttributes"
    ]
    resources = [var.sns_platform_notification_topic_arn]
  }
}

resource "aws_iam_policy" "csb_helper" {
  name        = "${var.stack_description}-csb-helper"
  description = "Policy for the CSB Helper web service, which supports the Cloud Service Broker."
  policy      = data.aws_iam_policy_document.csb_helper.json
}

resource "aws_iam_user" "csb_helper" {
  name = "${var.stack_description}-csb-helper"
}

resource "aws_iam_access_key" "csb_helper" {
  user = aws_iam_user.csb_helper.name
}

resource "aws_iam_user_policy_attachment" "csb_helper" {
  user       = aws_iam_user.csb_helper.name
  policy_arn = aws_iam_user.csb_helper.name
}

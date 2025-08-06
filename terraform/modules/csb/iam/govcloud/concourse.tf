data "aws_iam_policy_document" "concourse" {
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

resource "aws_iam_policy" "concourse" {
  name        = "${var.stack_description}-csb-concourse"
  description = "Used by the Concourse pipeline `csb`, which uses Terraform to deploy the CSB and CSB Helper. The pipeline manages a subscription to the platform notifications topic on behalf of the CSB Helper."
  policy      = data.aws_iam_policy_document.concourse.json
}

resource "aws_iam_user" "concourse" {
  name = "${var.stack_description}-concourse-csb"
}

resource "aws_iam_user_policy_attachment" "concourse" {
  user       = aws_iam_user.concourse.name
  policy_arn = aws_iam_policy.concourse.arn
}

resource "aws_iam_access_key" "concourse" {
  user = aws_iam_user.concourse.name
}

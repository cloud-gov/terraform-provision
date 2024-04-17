resource "aws_sns_topic" "cg_platform_notifications" {
  name = var.sns_cg_platform_notifications_name
}

resource "aws_sns_topic" "cg_platform_slack_notifications" {
  name = var.sns_cg_platform_slack_notifications_name
}

resource "aws_sns_topic_subscription" "cg_platform_notifications" {
  topic_arn = aws_sns_topic.cg_platform_notifications.arn
  protocol  = "email"
  endpoint  = var.sns_cg_platform_notifications_email
}

resource "aws_sns_topic_subscription" "cg_platform_slack_notifications" {
  topic_arn = aws_sns_topic.cg_platform_slack_notifications.arn
  protocol  = "email"
  endpoint  = var.sns_cg_platform_slack_notifications_email
}

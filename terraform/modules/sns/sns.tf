resource "aws_sns_topic" "cg_notifications" {
  name = var.sns_main_name
}

resource "aws_sns_topic" "cg_platform_notifications" {
  name = var.sns_slack_name
}

resource "aws_sns_topic_subscription" "cg_notifications" {
  topic_arn = aws_sns_topic.cg_notifications.arn
  protocol  = "email"
  endpoint  = var.sns_main_endpoint
}

resource "aws_sns_topic_subscription" "cg_platform_notifications" {
  topic_arn = aws_sns_topic.cg_platform_notifications.arn
  protocol  = "email"
  endpoint  = var.sns_slack_endpoint
}

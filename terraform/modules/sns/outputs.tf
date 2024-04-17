output "cg_platform_notifications_arn" {
  value = aws_sns_topic.cg_platform_notifications.arn
}

output "cg_platform_slack_notifications_arn" {
  value = aws_sns_topic.cg_platform_slack_notifications.arn
}

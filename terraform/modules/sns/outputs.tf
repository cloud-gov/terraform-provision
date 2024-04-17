output "sns_arn" {
  value = aws_sns_topic.cg_notifications.arn
}

output "sns_slack_arn" {
  value = aws_sns_topic.cg_platform_notifications.arn
}

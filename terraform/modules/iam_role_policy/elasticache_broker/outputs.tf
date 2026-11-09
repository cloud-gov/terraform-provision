output "name" {
  value = aws_iam_policy.iam_policy.name
}

output "arn" {
  value = aws_iam_policy.iam_policy.arn
}

output "platform_name" {
  value = aws_iam_policy.platform_iam_policy.name
}

output "platform_arn" {
  value = aws_iam_policy.platform_iam_policy.arn
}

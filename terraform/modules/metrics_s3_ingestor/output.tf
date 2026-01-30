output "metric_lambda_function_name" {
  value = aws_lambda_function.transform[each.key]
}

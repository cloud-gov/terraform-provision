output "metric_lambda_function_name" {
  for_each = toset(var.environments)
  value = aws_lambda_function.transform[each.key]
}

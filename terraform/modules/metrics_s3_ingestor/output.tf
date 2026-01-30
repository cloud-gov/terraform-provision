output "metric_lambda_function_name" {
    value = {
    for env in var.environments : env => aws_lambda_function.transform[env].function_name
  }
}

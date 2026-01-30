output "cloudwatch_lambda_function_name" {
   value = {
    for i, env in var.environments : env => element(aws_lambda_function.transform[*].function_name, i)
  }
}
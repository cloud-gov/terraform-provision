output "metric_streams" {
  description = "opensearch environment metric stream details"
  value = {
    for env in var.environments : env => {
      name = aws_cloudwatch_metric_stream.main[env].name
      arn  = aws_cloudwatch_metric_stream.main[env].arn
    }
  }

}

output "firehose_delivery_streams" {
  description = "opensearch environment firehose delivery stream details"
  value = {
    for env in var.environments : env => {
      name = aws_kinesis_firehose_delivery_stream.metric_stream[env].name
      arn  = aws_kinesis_firehose_delivery_stream.metric_stream[env].arn
    }
  }
}

output "lambda_functions" {
  description = "lambda functions for each environment details"
  value = {
    for env in var.environments : env => {
      name = aws_lambda_function.transform[env].function_name
      arn  = aws_lambda_function.transform[env].arn
    }
  }
}

output "s3_buckets" {
  description = "opensearch s3 bucket for metrics"
  value = {
    for env in var.environments : env => {
      name = aws_s3_bucket.opensearch_metric_buckets[env].bucket
      arn  = aws_s3_bucket.opensearch_metric_buckets[env].arn
    }
  }
}

output "environments" {
  description = "environments"
  value       = var.environments
}

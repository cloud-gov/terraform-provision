output "bucket_name" {
  value = aws_s3_bucket.log_encrypted_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.log_encrypted_bucket.arn
}

output "sqs_queue_url" {
  value = var.enable_sqs_notification ? aws_sqs_queue.object_created_queue[0].id : null
}

output "sqs_queue_arn" {
  value = var.enable_sqs_notification ? aws_sqs_queue.object_created_queue[0].arn : null
}

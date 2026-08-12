output "platform_logs_bucket_access_key_id_prev" {
  value = ""
}

output "platform_logs_bucket_secret_access_key_prev" {
  value = ""
}

output "platform_logs_bucket_access_key_id_curr" {
  value = aws_iam_access_key.iam_access_key_v2.id
}

output "platform_logs_bucket_secret_access_key_curr" {
  value     = aws_iam_access_key.iam_access_key_v2.secret
  sensitive = true
}

output "platform_logs_bucket_name" {
  value = aws_s3_bucket.log_bucket.id
}

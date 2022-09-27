output "bucket_name" {
  value = aws_s3_bucket.log_encrypted_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.log_encrypted_bucket.arn
}
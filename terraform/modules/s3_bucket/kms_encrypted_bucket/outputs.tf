output "bucket_name" {
  value = aws_s3_bucket.kms_encrypted_bucket.id
}

output "bucket_kms_key_arn" {
  value = aws_kms_key.encryption_key.arn
}

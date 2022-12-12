output "bucket_name" {
  value = aws_s3_bucket.kms_encrypted_bucket.id
}


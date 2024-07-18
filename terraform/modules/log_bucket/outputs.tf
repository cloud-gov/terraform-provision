output "elb_bucket_name" {
  value = aws_s3_bucket.log_bucket.id
}

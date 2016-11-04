output "bucket_name" {
  value = "${aws_s3_bucket.encrypted_bucket.bucket}"
}

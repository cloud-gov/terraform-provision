module "platform_archive" {
  source          = "../s3_bucket/encrypted_bucket"
  bucket          = "logsearch-platform-${var.stack_description}"
  aws_partition   = var.aws_partition
  expiration_days = 548
}
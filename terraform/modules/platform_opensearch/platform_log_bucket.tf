
resource "aws_s3_bucket" "log_bucket" {
  bucket = "logs-platform-opensearch-${var.stack_description}"
}
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    id     = "all"
    status = "Enabled"
    filter {}
    expiration {
      days = 365 # 1 year
    }
  }
  transition_default_minimum_object_size = "varies_by_storage_class"
}

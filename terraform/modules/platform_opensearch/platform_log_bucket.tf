
resource "aws_s3_bucket" "log_bucket" {
  bucket = "logs-platform-opensearch-${var.stack_description}"
}
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    id     = "all"
    status = "Enabled"
    filter {}
    transition {
      days          = 365
      storage_class = "ONEZONE_IA"
    }
    expiration {
      days = 930 # 31 days * 30 months = 930 days
    }
  }
  transition_default_minimum_object_size = "varies_by_storage_class"
}


resource "aws_s3_bucket" "snapshot_bucket" {
  bucket = "logs-platform-snapshot-${var.stack_description}"
}
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.snapshot.id
  rule {
    id     = "all"
    status = "Enabled"
    filter {}
    expiration {
      days = 403 # 31 days * 13 months = 403 days
    }
  }
  transition_default_minimum_object_size = "varies_by_storage_class"
}

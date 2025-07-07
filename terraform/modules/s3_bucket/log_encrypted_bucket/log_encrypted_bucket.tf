resource "aws_s3_bucket" "log_encrypted_bucket" {
  bucket        = var.bucket
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_public_access_block" "log_encrypted_bucket_block_public" {
  bucket = aws_s3_bucket.log_encrypted_bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_encrypted_bucket_sse_config" {
  bucket = aws_s3_bucket.log_encrypted_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "log_encrypted_bucket_acl_ownership" {
  count  = var.acl != "" && var.object_ownership != "" ? 1 : 0
  bucket = aws_s3_bucket.log_encrypted_bucket.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_versioning" "log_encrypted_bucket_versioning" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.log_encrypted_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_acl" "log_encrypted_bucket_acl" {
  count      = var.acl != "" ? 1 : 0
  bucket     = aws_s3_bucket.log_encrypted_bucket.id
  acl        = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.log_encrypted_bucket_acl_ownership]
}

resource "aws_s3_bucket_lifecycle_configuration" "log_encrypted_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_encrypted_bucket.id
  rule {
    id     = "log-rule"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    dynamic "expiration" {
      for_each = var.expiration_days == 0 ? [] : [var.expiration_days]

      content {
        days = expiration.value
      }
    }
  }
  transition_default_minimum_object_size = "varies_by_storage_class"
}

resource "aws_s3_bucket_logging" "log_encrypted_bucket_access_logging" {
  count         = var.access_logging_target_bucket != "" ? 1 : 0
  bucket        = aws_s3_bucket.log_encrypted_bucket.id
  target_bucket = var.access_logging_target_bucket
  target_prefix = var.access_logging_target_bucket_prefix
}

resource "aws_s3_bucket" "kms_encrypted_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.kms_encrypted_bucket.id
  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_kms_config" {
  bucket = aws_s3_bucket.kms_encrypted_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "encrypted_bucket_acl" {
  bucket = aws_s3_bucket.kms_encrypted_bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.kms_encrypted_bucket.id
  policy = data.aws_iam_policy_document.config_bucket_policy.json
}

resource "aws_s3_bucket_lifecycle_configuration" "log_encrypted_bucket_lifecycle" {
  bucket = aws_s3_bucket.kms_encrypted_bucket.id
  rule {
    id = "config-logs-lifecycle-rule"
    
    filter { }

    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

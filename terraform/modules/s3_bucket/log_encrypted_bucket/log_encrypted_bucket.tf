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
  count  = var.acl != "" ? 1 : 0
  bucket = aws_s3_bucket.log_encrypted_bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_lifecycle_configuration" "log_encrypted_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_encrypted_bucket.id
  rule {
    id = "log-rule"
    filter {
      prefix = ""
    }
    #if expiration_days is 0 then the rule is disabled
    status = var.expiration_days == 0 ? "Disabled" : "Enabled"
    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
    expiration {
      # Hack: Set expiration days to 30 if unset; objects won't actually be expired because the rule will be disabled
      # See https://github.com/terraform-providers/terraform-provider-aws/issues/1402
      days = var.expiration_days == 0 ? 30 : var.expiration_days
    }
  }
}

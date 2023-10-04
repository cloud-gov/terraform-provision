resource "aws_s3_bucket" "kms_encrypted_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "kms_encrypted_bucket_block_public" {
  bucket = aws_s3_bucket.kms_encrypted_bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "kms_encrypted_bucket_versioning" {
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

resource "aws_s3_bucket_acl" "kms_encrypted_bucket_acl" {
  count      = var.acl != "" ? 1 : 0
  bucket     = aws_s3_bucket.kms_encrypted_bucket.id
  acl        = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.kms_encrypted_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "kms_encrypted_bucket_acl_ownership" {
  count  = var.acl != "" && var.object_ownership != "" ? 1 : 0
  bucket = aws_s3_bucket.kms_encrypted_bucket.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "kms_encrypted_bucket_lifecycle" {
  bucket = aws_s3_bucket.kms_encrypted_bucket.id
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = lookup(rule.value, "id", null)
      prefix = lookup(rule.value, "prefix", null)
      status = rule.value.enabled

      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [rule.value.expiration]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }
    }
  }
}

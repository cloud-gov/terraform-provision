resource "aws_s3_bucket" "encrypted_bucket" {
  bucket        = var.bucket
  force_destroy = var.force_destroy
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encrypted_bucket_sse_config" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.server_side_encryption
    }
  }
}

resource "aws_s3_bucket_versioning" "encrypted_bucket_versioning" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.encrypted_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_acl" "encrypted_bucket_acl" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_lifecycle_configuration" "encrypted_bucket_lifecycle" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  # create the lifecycle configuration if expiration days are set or the
  # bucket is versioned (so we can clean up noncurrent versions)
  count = var.expiration_days == 0 && !tobool(var.versioning) ? 0 : 1

  dynamic "rule" {
    # if expiration_days is 0 then the expiration rule is not created
    for_each = var.expiration_days == 0 ? [] : [var.expiration_days]

    content {
      id     = "expiration-rule"
      status = "Enabled"

      filter {}

      expiration {
        days = rule.value
      }
    }
  }

  # on versioned buckets, the expiration rule above only makes the current object
  # version noncurrent. This rule removes noncurrent versions, expired delete markers, and aborts incomplete multipart uploads.
  dynamic "rule" {
    for_each = tobool(var.versioning) ? [1] : []

    content {
      id     = "cleanup-noncurrent-versions"
      status = "Enabled"

      filter {}

      noncurrent_version_expiration {
        noncurrent_days = 1
      }

      expiration {
        expired_object_delete_marker = true
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = 1
      }
    }
  }

  transition_default_minimum_object_size = "varies_by_storage_class"
}

resource "aws_s3_bucket_policy" "encrypted_bucket_policy" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "DenyUnencryptedPut",
        "Effect": "Deny",
        "Principal": {
            "AWS": "*"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:${var.aws_partition}:s3:::${var.bucket}/*",
        "Condition": {
            "StringNotEquals": {
                "s3:x-amz-server-side-encryption": "${var.server_side_encryption}"
            }
        }
    }]
}
EOF

}

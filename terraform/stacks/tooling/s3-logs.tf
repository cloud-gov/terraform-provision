# 2023-06-13 - This CloudTrail is no longer necessary, so the trail resources were removed
# but the buckets keeping an archive of CloudTrail logs are being kept in accordance with
# M-21-31. These bucket resources can be deleted on or after **December 30, 2025**.

resource "aws_s3_bucket" "cg-s3-cloudtrail-bucket" {
  bucket        = var.cloudtrail_bucket
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_audit_logs_trail_bucket_lifecycle" {
  bucket = aws_s3_bucket.cg-s3-cloudtrail-bucket.id
  rule {
    id = "all-logs-rule"
    filter {
      prefix = ""
    }
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
    expiration {
      days = 930 # ~30 months for M-21-31 compliance
    }
  }
}

resource "aws_s3_bucket" "cloudtrail-accesslog-bucket" {
  bucket = var.cloudtrail_accesslog_bucket
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_access_logs_trail_bucket_lifecycle" {
  bucket = aws_s3_bucket.cloudtrail-accesslog-bucket.id
  rule {
    id = "all-logs-rule"
    filter {
      prefix = ""
    }
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
    expiration {
      days = 930 # ~30 months for M-21-31 compliance
    }
  }
}

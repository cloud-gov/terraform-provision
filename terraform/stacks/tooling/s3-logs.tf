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

resource "aws_s3_bucket_logging" "cg-s3-cloudtrail-bucket-logging" {
  bucket = aws_s3_bucket.cg-s3-cloudtrail-bucket.id

  target_bucket = aws_s3_bucket.cloudtrail-accesslog-bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket" "cloudtrail-accesslog-bucket" {
  bucket = var.cloudtrail_accesslog_bucket
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail-accesslog-bucket-ownership" {
  bucket = aws_s3_bucket.cloudtrail-accesslog-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudtrail-accesslog-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudtrail-accesslog-bucket-ownership]
  bucket     = aws_s3_bucket.cloudtrail-accesslog-bucket.id
  acl        = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cg-s3-cloudtrail-bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:${data.aws_partition.current.partition}:s3:::${var.cloudtrail_bucket}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:${data.aws_partition.current.partition}:s3:::${var.cloudtrail_bucket}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_policy" "cloudtrail_accesslog_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail-accesslog-bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3ServerAccessLogsPolicy",
            "Effect": "Allow",
            "Principal": {
                "Service": "logging.s3.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:${data.aws_partition.current.partition}:s3:::${var.cloudtrail_accesslog_bucket}/*",
            "Condition": {
                "ArnLike": {
                    "aws:SourceArn": "arn:${data.aws_partition.current.partition}:s3:::${var.cloudtrail_bucket}"
                },
                "StringEquals": {
                    "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_access_logs_trail_bucket_lifecycle" {
  bucket = aws_s3_bucket.cloudtrail-accesslog-bucket.id
  rule {
    id = "all-logs-rule"
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

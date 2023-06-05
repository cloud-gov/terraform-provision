resource "aws_s3_bucket" "cg-s3-cloudtrail-bucket" {
  bucket        = var.cloudtrail_bucket
  force_destroy = true
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
        },
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

resource "aws_cloudtrail" "cg-s3-cloudtrail-trail" {
  name                       = "s3-audit-logs"
  s3_bucket_name             = aws_s3_bucket.cg-s3-cloudtrail-bucket.id
  enable_log_file_validation = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:${data.aws_partition.current.partition}:s3:::"]
    }
  }
}


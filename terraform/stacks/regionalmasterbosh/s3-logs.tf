resource "aws_s3_bucket" "cg-s3-cloudtrail-bucket" {
  bucket        = var.cloudtrail_bucket
  force_destroy = true

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


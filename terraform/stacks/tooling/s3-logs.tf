resource "aws_s3_bucket" "cg-s3-cloudtrail-bucket" {
  bucket        = "cg-s3-cloudtrail"
  force_destroy = true

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
            "Resource": "arn:${local.aws_partition}:s3:::cg-s3-cloudtrail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:${local.aws_partition}:s3:::cg-s3-cloudtrail/*",
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

resource "aws_cloudtrail" "cg-s3-cloudtrail-trail"{
  name                          = "s3-audit-logs"
  s3_bucket_name                = "${aws_s3_bucket.cg-s3-cloudtrail-bucket.id}"
  event_selector {
    read_write_type = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:${local.aws_partition}:s3:::cg-*/*"]
    }
  }
}



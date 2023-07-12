resource "aws_s3_bucket" "semver_bucket" {
  bucket              = var.bucket
  force_destroy       = var.force_destroy
  object_lock_enabled = "false"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.semver_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cvd_public_access_block" {
  bucket = aws_s3_bucket.semver_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypted_bucket_sse_config" {
  bucket = aws_s3_bucket.semver_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.semver_bucket.id
    policy = <<POLICY
{
  "Statement": [
    {
      "Action": "s3:GetBucketAcl",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.us-gov-west-1.amazonaws.com"
      },
      "Resource": "arn:${var.aws_partition}:s3:::${var.bucket}"
    },
    {
      "Action": "s3:PutObject",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.us-gov-west-1.amazonaws.com"
      },
      "Resource": "arn:${var.aws_partition}:s3:::${var.bucket}/*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

}



resource "aws_s3_bucket_request_payment_configuration" "bucket_payer" {
  bucket = aws_s3_bucket.semver_bucket.id
  payer  = "BucketOwner"
}
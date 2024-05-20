resource "aws_s3_bucket" "encrypted_bucket" {
  bucket        = var.bucket
  force_destroy = var.force_destroy
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encrypted_bucket_sse_config" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
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
  # since the only rule is an expiration rule, we only create the lifecycle
  # configuration if expiration days are set
  count = var.expiration_days == 0 ? 0 : 1

  dynamic "rule" {
    for_each = var.expiration_days == 0 ? [] : [var.expiration_days]

    content {
      id = "expiration-rule"
      status = "Enabled"

      expiration {
        days = rule.value
      }
    }
  }
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
                "s3:x-amz-server-side-encryption": "AES256"
            }
        }
    }]
}
EOF

}


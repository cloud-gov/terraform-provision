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

#resource "aws_s3_bucket_acl" "encrypted_bucket_acl" {
#  depends_on = [ aws_s3_bucket.encrypted_bucket, aws_s3_bucket_policy.encrypted_bucket_policy, aws_s3_bucket_lifecycle_configuration.encrypted_bucket_lifecycle ]
#  bucket = aws_s3_bucket.encrypted_bucket.id
##  #acl    = var.acl
#  acl = "private"
#}

resource "aws_s3_bucket_lifecycle_configuration" "encrypted_bucket_lifecycle" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  # since the only rule is an expiration rule, we only create the lifecycle
  # configuration if expiration days are set
  count = var.expiration_days == 0 ? 0 : 1

  dynamic "rule" {
    # if expiration_days is 0 then the rule is not created
    for_each = var.expiration_days == 0 ? [] : [var.expiration_days]

    content {
      id     = "expiration-rule"
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
                "s3:x-amz-server-side-encryption": "${var.server_side_encryption}"
            }
        }
    }]
}
EOF

}

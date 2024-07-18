resource "aws_s3_bucket" "cvd_bucket" {
  bucket        = var.bucket
  force_destroy = var.force_destroy
}
resource "aws_s3_bucket_server_side_encryption_configuration" "public_encrypted_bucket_sse_config" {
  bucket = aws_s3_bucket.cvd_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_website_configuration" "bucket_website_configuration" {
  bucket = aws_s3_bucket.cvd_bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_encrypted_bucket_policy" {

  depends_on = [aws_s3_bucket_public_access_block.cvd_public_access_block]

  bucket = aws_s3_bucket.cvd_bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:${var.aws_partition}:s3:::${var.bucket}/*"
        },
        {
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
        }
    ]
}
EOF

}

resource "aws_s3_bucket_public_access_block" "cvd_public_access_block" {
  bucket = aws_s3_bucket.cvd_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

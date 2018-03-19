resource "aws_s3_bucket" "public_encrypted_bucket" {
    bucket = "${var.bucket}"
    force_destroy = "${var.force_destroy}"
    versioning {
        enabled = "${var.versioning}"
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowRead",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
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

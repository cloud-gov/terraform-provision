resource "aws_s3_bucket" "encrypted_bucket" {
    bucket = "${var.bucket}"
    acl = "${var.acl}"
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

    lifecycle_rule {
        prefix = ""
        enabled = "${var.expiration_days == 0 ? "false" : "true"}"
        enabled = "${lookup(map("0", "false"), var.expiration_days, "true")}"
        expiration {
            # Hack: Set expiration days to 30 if unset; objects won't actually be expired because the rule will be disabled
            # See https://github.com/terraform-providers/terraform-provider-aws/issues/1402
            days = "${var.expiration_days == 0 ? 30 : var.expiration_days}"
        }
    }

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

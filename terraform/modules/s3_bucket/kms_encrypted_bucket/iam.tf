data "aws_iam_policy_document" "config_bucket_policy" {
  statement {
    sid = "DenyIncorrectEncryptionHeader"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.kms_encrypted_bucket.id}/*"
    ]

    condition {
      test = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values = ["aws:kms"]
    }
  }

  statement {
    sid = "DenyUnEncryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.kms_encrypted_bucket.id}/*"
    ]

    condition {
      test = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values = [true]
    }
  }
}
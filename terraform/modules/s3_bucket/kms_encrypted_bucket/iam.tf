data "aws_iam_policy_document" "kms_encrypted_bucket_policy" {
  source_policy_documents = var.source_bucket_policy_documents

  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${aws_s3_bucket.kms_encrypted_bucket.id}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${aws_s3_bucket.kms_encrypted_bucket.id}/*"
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = [true]
    }
  }

  dynamic "statement" {
    for_each = var.allowed_external_account_ids
    iterator = account

    content {
      sid    = "AllowExternalAccountAccess_${account.value}"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = ["arn:${var.aws_partition}:iam::${account.value}:root"]
      }

      actions = [
        "s3:*"
      ]

      resources = [
        "arn:${var.aws_partition}:s3:::${aws_s3_bucket.kms_encrypted_bucket.id}",
        "arn:${var.aws_partition}:s3:::${aws_s3_bucket.kms_encrypted_bucket.id}/*"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "kms_bucket_policy" {
  bucket = aws_s3_bucket.kms_encrypted_bucket.id
  policy = data.aws_iam_policy_document.kms_encrypted_bucket_policy.json
}
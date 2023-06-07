data "aws_iam_policy_document" "log_encrypted_bucket_deny_unencrypted_policy" {
  count                   = var.include_require_encrypted_put_bucket_policy ? 1 : 0
  source_policy_documents = var.source_bucket_policy_documents

  statement {
    sid    = "DenyUnencryptedPut"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${aws_s3_bucket.log_encrypted_bucket.id}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES:256"]
    }
  }
}

data "aws_iam_policy_document" "log_encrypted_bucket_policy" {
  count = var.include_require_encrypted_put_bucket_policy || length(var.source_bucket_policy_documents) > 0 ? 1 : 0
  source_policy_documents = concat(
    var.source_bucket_policy_documents,
    var.include_require_encrypted_put_bucket_policy ? [data.aws_iam_policy_document.log_encrypted_bucket_deny_unencrypted_policy[0].json] : []
  )
}

resource "aws_s3_bucket_policy" "log_encrypted_bucket_policy" {
  count  = var.include_require_encrypted_put_bucket_policy || length(var.source_bucket_policy_documents) > 0 ? 1 : 0
  bucket = aws_s3_bucket.log_encrypted_bucket.id
  policy = data.aws_iam_policy_document.log_encrypted_bucket_policy.json
}

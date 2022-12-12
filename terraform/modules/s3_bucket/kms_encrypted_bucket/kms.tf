data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      "*"
    ]

    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = ["s3.${var.region}.amazonaws.com"]
    }

    condition {
      test = "StringEquals"
      variable = "kms:CallerAccount"
      values = [var.kms_account_id]
    }
  }
}

resource "aws_kms_key" "encryption_key" {
  description         = "KMS key used to encrypt bucket objects for ${var.bucket_name}"
  policy              = data.aws_iam_policy_document.kms_key_policy.json
  enable_key_rotation = true
}

resource "aws_kms_alias" "default" {
  name          = format("alias/s3-%v", aws_s3_bucket.kms_encrypted_bucket.id)
  target_key_id = aws_kms_key.encryption_key.id
}
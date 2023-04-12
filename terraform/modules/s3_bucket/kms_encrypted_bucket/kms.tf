data "aws_iam_policy_document" "kms_key_policy" {
  source_policy_documents = var.source_kms_key_policy_documents

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${var.aws_partition}:iam::${var.kms_account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [for role in var.kms_admin_roles : "arn:${var.aws_partition}:iam::${var.kms_account_id}:role/${role}"]
    }

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowKeyUse"
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
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${var.region}.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.kms_account_id]
    }
  }

  dynamic "statement" {
    for_each = var.allowed_external_account_ids
    iterator = account

    content {
      sid    = "AllowExternalKMSKeyAccess_${account.value}"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = ["arn:${var.aws_partition}:iam::${account.value}:root"]
      }

      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]

      resources = [
        "*"
      ]
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
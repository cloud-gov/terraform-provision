resource "aws_s3_bucket" "opensearch_cloudwatch_buckets" {
  for_each = toset(var.environments)
  bucket   = "logs-${var.name_prefix}-${each.key}-cloudwatch"
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "buckets_encryption" {
  for_each = aws_s3_bucket.opensearch_cloudwatch_buckets

  bucket = each.value.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "opensearch_buckets_deny_unencrypted_policy" {
  for_each = aws_s3_bucket.opensearch_cloudwatch_buckets

  statement {
    sid    = "AllowFirehoseRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_role[each.key].arn,"arn:${var.aws_partition}:sts::${var.account_id}:assumed-role/${var.ingestor_arn}"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:${var.aws_partition}:s3:::${each.value.id}/*"
    ]
  }

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
      "${aws_s3_bucket.opensearch_cloudwatch_buckets[each.key].arn}/*"
    ]
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:${var.aws_partition}:iam::${var.account_id}:role/${var.ingestor_arn}"]
    }
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:${var.aws_partition}:sts::${var.account_id}:assumed-role/${var.ingestor_arn}"]
    }
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_role.lambda_role[each.key].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "opensearch_buckets_policy" {
  for_each = aws_s3_bucket.opensearch_cloudwatch_buckets

  bucket = each.value.id
  policy = data.aws_iam_policy_document.opensearch_buckets_deny_unencrypted_policy[each.key].json
}
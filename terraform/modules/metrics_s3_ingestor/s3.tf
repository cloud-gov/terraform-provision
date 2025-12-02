resource "aws_s3_bucket" "opensearch_metric_buckets" {
  for_each = toset(var.environments)
  bucket   = "logs-${var.name_prefix}-${each.key}-metrics"
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "buckets_encryption" {
  for_each = aws_s3_bucket.opensearch_metric_buckets

  bucket = each.value.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "opensearch_buckets_deny_unencrypted_policy" {
  for_each = var.include_require_encrypted_put_bucket_policy ? aws_s3_bucket.opensearch_metric_buckets : {}
  
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
      "arn:${var.aws_partition}:s3:::${each.value.id}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }
}

resource "aws_s3_bucket_policy" "opensearch_buckets_policy" {
  for_each = aws_s3_bucket.opensearch_metric_buckets
  
  bucket = each.value.id
  policy = data.aws_iam_policy_document.opensearch_buckets_deny_unencrypted_policy[each.key].json
}
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
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

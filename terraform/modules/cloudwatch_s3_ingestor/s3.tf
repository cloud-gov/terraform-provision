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
  }
}

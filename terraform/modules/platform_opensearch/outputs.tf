/* Opensearchsearch ELB */

output "platform_opensearch_lb_target_group" {
  value = aws_lb_target_group.platform_dashboard.name
}

output "platform-opensearch_bucket_access_key_id_prev" {
  value = ""
}

output "platform-opensearch_bucket_secret_access_key_prev" {
  value = ""
}

output "platform-opensearch_bucket_access_key_id_curr" {
  value = aws_iam_access_key.iam_access_key_v2.id
}

output "platform-opensearch_bucket_secret_access_key_curr" {
  value     = aws_iam_access_key.iam_access_key_v2.secret
  sensitive = true
}

output "platform-opensearch_bucket_name" {
  value = aws_s3_bucket.log_bucket.id
}

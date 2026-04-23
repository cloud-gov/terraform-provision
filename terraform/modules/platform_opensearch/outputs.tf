/* Opensearchsearch ELB */

output "platform_opensearch_lb_target_group" {
  value = aws_lb_target_group.platform_dashboard.name
}

output "platform-opensearch_bucket_name" {
  value = aws_s3_bucket.log_bucket.id
}

/* Opensearchsearch ELB */

output "platform_opensearch_lb_target_group" {
  value = aws_lb_target_group.platform_dashboard.name
}

output "platform_syslog_udp_nlb_dns_name" {
  value = aws_lb.platform_syslog_udp_nlb.dns_name
}

# Target group name is what BOSH registers instances into via
# cloud_properties.lb_target_groups.
output "platform_syslog_udp_lb_target_group" {
  value = aws_lb_target_group.platform_syslog_udp.name
}

output "platform-opensearch_bucket_name" {
  value = aws_s3_bucket.log_bucket.id
}


output "platform-snapshot_bucket_name" {
  value = aws_s3_bucket.snapshot_bucket.id
}

output "platform-snapshot_bucket_arn" {
  value = aws_s3_bucket.snapshot_bucket.arn
}

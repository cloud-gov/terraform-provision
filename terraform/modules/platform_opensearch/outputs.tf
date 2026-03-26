/* Logsearch ELB */

output "platform_opensearch_syslog_elb_name" {
  value = aws_elb.platform_opensearch_syslog_elb.name
}

output "platform_opensearch_syslog_elb_dns_name" {
  value = aws_elb.platform_opensearch_syslog_elb.dns_name
}

output "platform_opensearch_lb_target_group" {
  value = aws_lb_target_group.platform_dashboard.name
}

output "platform_opensearch_logs_bucket_access_key_id_prev" {
  value = ""
}

output "platform_opensearch_logs_bucket_secret_access_key_prev" {
  value = ""
}

output "platform_opensearch_logs_bucket_access_key_id_curr" {
  value = aws_iam_access_key.iam_access_key_v2.id
}

output "platform_opensearch_logs_bucket_secret_access_key_curr" {
  value     = aws_iam_access_key.iam_access_key_v2.secret
  sensitive = true
}
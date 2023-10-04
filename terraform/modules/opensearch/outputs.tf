/* Logsearch ELB */
# output "logsearch_elb_name" {
#   value = aws_elb.logsearch_elb.name
# }

# output "logsearch_elb_dns_name" {
#   value = aws_elb.logsearch_elb.dns_name
# }

output "platform_syslog_elb_name" {
  value = aws_elb.platform_syslog_elb.name
}

output "platform_syslog_elb_dns_name" {
  value = aws_elb.platform_syslog_elb.dns_name
}

# output "platform_kibana_lb_target_group" {
#   value = aws_lb_target_group.platform_kibana.name
# }

output "platform_logs_bucket_access_key_id_prev" {
  value = ""
}

output "platform_logs_bucket_secret_access_key_prev" {
  value = ""
}

output "platform_logs_bucket_access_key_id_curr" {
  value = aws_iam_access_key.iam_access_key_v1.id
}

output "platform_logs_bucket_secret_access_key_curr" {
  value = aws_iam_access_key.iam_access_key_v1.secret
}

output "platform_logs_bucket_name" {
  value = aws_s3_bucket.log_bucket.id
}

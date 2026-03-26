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

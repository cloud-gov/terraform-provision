/* Logsearch ELB */
output "logsearch_elb_name" {
  value = "${aws_elb.logsearch_elb.name}"
}
output "logsearch_elb_dns_name" {
  value = "${aws_elb.logsearch_elb.dns_name}"
}

output "platform_syslog_elb_name" {
  value = "${aws_elb.platform_syslog_elb.name}"
}
output "platform_syslog_elb_dns_name" {
  value = "${aws_elb.platform_syslog_elb.dns_name}"
}

output "platform_kibana_elb_name" {
  value = "${aws_elb.platform_kibana_elb.name}"
}
output "platform_kibana_elb_dns_name" {
  value = "${aws_elb.platform_kibana_elb.dns_name}"
}

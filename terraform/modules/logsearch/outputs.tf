/* Logsearch ELB */
output "logsearch_elb_name" {
  value = "${aws_elb.logsearch_elb.name}"
}
output "logsearch_elb_dns_name" {
  value = "${aws_elb.logsearch_elb.dns_name}"
}

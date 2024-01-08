/* logs_opensearch ELB */
output "logs_opensearch_elb_name" {
  value = aws_elb.logs_opensearch_elb.name
}

output "logs_opensearch_elb_dns_name" {
  value = aws_elb.logs_opensearch_elb.dns_name
}

output "elasticsearch_subnet1_az1" {
  value = aws_subnet.az1_elasticsearch.id
}

output "elasticsearch_subnet2_az2" {
  value = aws_subnet.az2_elasticsearch.id
}

output "elasticsearch_subnet3_az1" {
  value = aws_subnet.az3_elasticsearch.id
}

output "elasticsearch_subnet4_az2" {
  value = aws_subnet.az4_elasticsearch.id
}

output "elasticsearch_private_cidr_1" {
  value = aws_subnet.az1_elasticsearch.cidr_block
}

output "elasticsearch_private_cidr_2" {
  value = aws_subnet.az2_elasticsearch.cidr_block
}

output "elasticsearch_private_cidr_3" {
  value = aws_subnet.az3_elasticsearch.cidr_block
}

output "elasticsearch_private_cidr_4" {
  value = aws_subnet.az4_elasticsearch.cidr_block
}

output "elasticsearch_security_group" {
  value = aws_security_group.elasticsearch.id
}
output "elasticsearch_log_group_audit" {
  value = aws_cloudwatch_log_group.audit_log.arn
}


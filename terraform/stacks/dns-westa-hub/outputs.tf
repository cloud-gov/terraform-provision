output "cloud_gov_ns" {
  value = aws_route53_zone.cloud_gov_zone.name_servers
}

output "cloud_gov_stage_ns" {
  value = aws_route53_zone.staging_zone.name_servers
}

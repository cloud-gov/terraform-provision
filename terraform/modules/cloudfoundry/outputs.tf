output "lb_name" {
  value = aws_lb.cf.name
}

output "lb_dns_name" {
  value = aws_lb.cf.dns_name
}

output "lb_arn_suffix" {
  value = aws_lb.cf.arn_suffix
}

output "apps_lb_name" {
  value = aws_lb.cf_apps.name
}

output "apps_lb_dns_name" {
  value = aws_lb.cf_apps.dns_name
}

output "lb_target_https_group" {
  value = aws_lb_target_group.cf_target_https.name
}

output "apps_lb_target_https_group" {
  value = aws_lb_target_group.cf_apps_target_https.name
}

output "logstash_lb_target_https_group" {
  value = aws_lb_target_group.cf_logstash_target_https.name
}

output "lb_gr_target_https_group" {
  value = aws_lb_target_group.cf_gr_target_https.name
}

output "apps_lb_gr_target_https_group" {
  value = aws_lb_target_group.cf_gr_apps_target_https.name
}

output "uaa_lb_gr_target_https_group" {
  value = aws_lb_target_group.cf_gr_uaa_target_https.name
}

output "uaa_lb_name" {
  value = aws_lb.cf_uaa.name
}

output "uaa_lb_dns_name" {
  value = aws_lb.cf_uaa.dns_name
}

output "uaa_lb_target_group" {
  value = aws_lb_target_group.cf_uaa_target.name
}

output "cf_rds_url" {
  value = module.cf_database_96.rds_url
}

output "cf_rds_host" {
  value = module.cf_database_96.rds_host
}

output "cf_rds_port" {
  value = module.cf_database_96.rds_port
}

output "cf_rds_username" {
  value = module.cf_database_96.rds_username
}

output "cf_rds_password" {
  value     = module.cf_database_96.rds_password
  sensitive = true
}

output "cf_rds_engine" {
  value = module.cf_database_96.rds_engine
}

/* Services network */
output "services_subnet_az1" {
  value = aws_subnet.az1_services.id
}

output "services_subnet_az2" {
  value = aws_subnet.az2_services.id
}

output "services_cidr_1" {
  value = aws_subnet.az1_services.cidr_block
}

output "services_cidr_2" {
  value = aws_subnet.az2_services.cidr_block
}

/* buckets */
output "buildpacks_bucket_name" {
  value = module.buildpacks.bucket_name
}

output "packages_bucket_name" {
  value = module.cc-packages.bucket_name
}

output "resources_bucket_name" {
  value = module.cc-resoures.bucket_name
}

output "droplets_bucket_name" {
  value = module.droplets.bucket_name
}

output "logsearch_archive_bucket_name" {
  value = module.logsearch-archive.bucket_name
}

output "logs_opensearch_archive_bucket_name" {
  value = module.logs-opensearch-archive.bucket_name
}

output "cf_uaa_waf_core_arn" {
  value = aws_wafv2_web_acl.cf_uaa_waf_core.arn
}

output "tcp_lb_names" {
  value = aws_lb.cf_apps_tcp.*.name
}

output "tcp_lb_dns_names" {
  value = aws_lb.cf_apps_tcp.*.dns_name
}

output "tcp_lb_target_groups" {
  value = aws_lb_target_group.cf_apps_target_tcp.*.name
}

output "tcp_lb_listener_ports" {
  value = aws_lb_listener.cf_apps_tcp.*.port
}

output "tcp_lb_security_groups" {
  value = aws_security_group.nlb_traffic.*
}

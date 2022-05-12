# Declare values used in multiple outputs
locals {
  private_subnet_az1_reserved = "${cidrhost(module.stack.private_cidr_az1, 0)} - ${cidrhost(module.stack.private_cidr_az1, 3)}"
  private_subnet_az2_reserved = "${cidrhost(module.stack.private_cidr_az2, 0)} - ${cidrhost(module.stack.private_cidr_az2, 3)}"
  master_bosh_static_ip       = cidrhost(module.stack.private_cidr_az1, 6)
  bosh_static_ip              = cidrhost(module.stack.private_cidr_az1, 7)
  bosh_uaa_static_ips = [
    cidrhost(module.stack.private_cidr_az1, 4),
    cidrhost(module.stack.private_cidr_az1, 5),
  ]
  staging_dns_private_ips = [
    cidrhost(module.stack.private_cidr_az1, 8),
    cidrhost(module.stack.private_cidr_az1, 9),
  ]
  production_dns_private_ips = [
    cidrhost(module.stack.private_cidr_az1, 10),
    cidrhost(module.stack.private_cidr_az1, 11),
  ]
  production_smtp_private_ip = cidrhost(module.stack.private_cidr_az1, 12)
}

output "az1" {
  value = data.aws_availability_zones.available.names[0]
}

output "az2" {
  value = data.aws_availability_zones.available.names[1]
}

output "stack_description" {
  value = var.stack_description
}

/* VPC */
output "vpc_region" {
  value = var.aws_default_region
}

output "vpc_id" {
  value = module.stack.vpc_id
}

output "vpc_cidr" {
  value = module.stack.vpc_cidr
}

output "vpc_cidr_dns" {
  value = cidrhost(module.stack.vpc_cidr, 2)
}

/* Private network */
output "private_subnet_az1" {
  value = module.stack.private_subnet_az1
}

output "private_subnet_az2" {
  value = module.stack.private_subnet_az2
}

output "private_route_table_az1" {
  value = module.stack.private_route_table_az1
}

output "private_route_table_az2" {
  value = module.stack.private_route_table_az2
}

output "private_subnet_az1_cidr" {
  value = module.stack.private_cidr_az1
}

output "private_subnet_az2_cidr" {
  value = module.stack.private_cidr_az2
}

output "master_bosh_reserved" {
  value = concat(
    [local.private_subnet_az1_reserved],
    [local.master_bosh_static_ip],
    local.bosh_uaa_static_ips,
    local.staging_dns_private_ips,
    local.production_dns_private_ips,
    [local.production_smtp_private_ip],
  )
}

output "private_subnet_az1_reserved" {
  value = local.private_subnet_az1_reserved
}

output "private_subnet_az2_reserved" {
  value = local.private_subnet_az2_reserved
}

output "private_subnet_az1_gateway" {
  value = cidrhost(module.stack.private_cidr_az1, 1)
}

output "private_subnet_az2_gateway" {
  value = cidrhost(module.stack.private_cidr_az2, 1)
}

output "production_monitoring_subnet_reserved" {
  value = "${cidrhost(module.monitoring_production.monitoring_cidr, 0)} - ${cidrhost(module.monitoring_production.monitoring_cidr, 3)}"
}

output "staging_monitoring_subnet_reserved" {
  value = "${cidrhost(module.monitoring_staging.monitoring_cidr, 0)} - ${cidrhost(module.monitoring_staging.monitoring_cidr, 3)}"
}

output "production_monitoring_subnet_cidr" {
  value = module.monitoring_production.monitoring_cidr
}

output "staging_monitoring_subnet_cidr" {
  value = module.monitoring_staging.monitoring_cidr
}

output "production_monitoring_subnet_gateway" {
  value = cidrhost(module.monitoring_production.monitoring_cidr, 1)
}

output "staging_monitoring_subnet_gateway" {
  value = cidrhost(module.monitoring_staging.monitoring_cidr, 1)
}

output "master_bosh_static_ip" {
  value = local.master_bosh_static_ip
}

output "tooling_bosh_static_ip" {
  value = local.bosh_static_ip
}

output "bosh_static_ip" {
  value = local.bosh_static_ip
}

output "bosh_uaa_static_ips" {
  value = local.bosh_uaa_static_ips
}

output "bosh_network_static_ips" {
  value = concat([local.bosh_static_ip], local.bosh_uaa_static_ips)
}

/* Public network */
output "public_subnet_az1" {
  value = module.stack.public_subnet_az1
}

output "public_subnet_az2" {
  value = module.stack.public_subnet_az2
}

output "public_subnet_az1_cidr" {
  value = module.stack.public_cidr_az1
}

output "public_subnet_az2_cidr" {
  value = module.stack.public_cidr_az2
}

output "public_route_table" {
  value = module.stack.public_route_table
}

output "nat_egress_ip_az1" {
  value = module.stack.nat_egress_ip_az1
}

output "nat_egress_ip_az2" {
  value = module.stack.nat_egress_ip_az2
}

/* Security Groups */
output "bosh_security_group" {
  value = module.stack.bosh_security_group
}

output "local_vpc_traffic_security_group" {
  value = module.stack.local_vpc_traffic_security_group
}

output "web_traffic_security_group" {
  value = module.stack.web_traffic_security_group
}

output "nessus_security_group" {
  value = aws_security_group.nessus_traffic.id
}

output "bosh_uaa_security_group" {
  value = aws_security_group.bosh_uaa_traffic.id
}

/* RDS Network */
output "rds_subnet_az1" {
  value = module.stack.rds_subnet_az1
}

output "rds_subnet_az2" {
  value = module.stack.rds_subnet_az2
}

output "rds_subnet_group" {
  value = module.stack.rds_subnet_group
}

output "rds_mysql_security_group" {
  value = module.stack.rds_mysql_security_group
}

output "rds_postgres_security_group" {
  value = module.stack.rds_postgres_security_group
}

output "rds_mssql_security_group" {
  value = module.stack.rds_mssql_security_group
}

output "rds_oracle_security_group" {
  value = module.stack.rds_oracle_security_group
}

/* RDS Bosh Instance */
output "bosh_rds_url_curr" {
  value = module.stack.bosh_rds_url_curr
}

output "bosh_rds_host_curr" {
  value = module.stack.bosh_rds_host_curr
}

output "bosh_rds_url_prev" {
  value = module.stack.bosh_rds_url_prev
}

output "bosh_rds_host_prev" {
  value = module.stack.bosh_rds_host_prev
}

output "bosh_rds_port" {
  value = module.stack.bosh_rds_port
}

output "bosh_rds_username" {
  value = module.stack.bosh_rds_username
}

output "bosh_rds_password" {
  value = module.stack.bosh_rds_password
  sensitive = true
}

/* CredHub RDS */
output "credhub_rds_url" {
  value = module.stack.credhub_rds_url
}

output "credhub_rds_host" {
  value = module.stack.credhub_rds_host
}

output "credhub_rds_port" {
  value = module.stack.credhub_rds_port
}

output "credhub_rds_username" {
  value = module.stack.credhub_rds_username
}

output "credhub_rds_password" {
  value = module.stack.credhub_rds_password
  sensitive = true
}

/* Main LB */
output "main_lb_name" {
  value = aws_lb.main.name
}

output "main_lb_dns_name" {
  value = aws_lb.main.dns_name
}

/* Production Concourse */
output "production_concourse_subnet" {
  value = module.concourse_production.concourse_subnet
}

output "production_concourse_subnet_reserved" {
  value = "${cidrhost(module.concourse_production.concourse_subnet_cidr, 0)} - ${cidrhost(module.concourse_production.concourse_subnet_cidr, 3)}"
}

output "production_concourse_subnet_cidr" {
  value = module.concourse_production.concourse_subnet_cidr
}

output "production_concourse_subnet_gateway" {
  value = cidrhost(module.concourse_production.concourse_subnet_cidr, 1)
}

output "production_concourse_security_group" {
  value = module.concourse_production.concourse_security_group
}

output "production_concourse_rds_identifier" {
  value = module.concourse_production.concourse_rds_identifier
}

output "production_concourse_rds_name" {
  value = module.concourse_production.concourse_rds_name
}

output "production_concourse_rds_host" {
  value = module.concourse_production.concourse_rds_host
}

output "production_concourse_rds_port" {
  value = module.concourse_production.concourse_rds_port
}

output "production_concourse_rds_url" {
  value = module.concourse_production.concourse_rds_url
}

output "production_concourse_rds_username" {
  value = module.concourse_production.concourse_rds_username
}

output "production_concourse_rds_password" {
  value = module.concourse_production.concourse_rds_password
  sensitive = true
}

output "production_concourse_lb_target_group" {
  value = module.concourse_production.concourse_lb_target_group
}

/* Staging Concourse */
output "staging_concourse_subnet" {
  value = module.concourse_staging.concourse_subnet
}

output "staging_concourse_subnet_reserved" {
  value = "${cidrhost(module.concourse_staging.concourse_subnet_cidr, 0)} - ${cidrhost(module.concourse_staging.concourse_subnet_cidr, 3)}"
}

output "staging_concourse_subnet_cidr" {
  value = module.concourse_staging.concourse_subnet_cidr
}

output "staging_concourse_subnet_gateway" {
  value = cidrhost(module.concourse_staging.concourse_subnet_cidr, 1)
}

output "staging_concourse_security_group" {
  value = module.concourse_staging.concourse_security_group
}

output "staging_concourse_rds_identifier" {
  value = module.concourse_staging.concourse_rds_identifier
}

output "staging_concourse_rds_name" {
  value = module.concourse_staging.concourse_rds_name
}

output "staging_concourse_rds_host" {
  value = module.concourse_staging.concourse_rds_host
}

output "staging_concourse_rds_port" {
  value = module.concourse_staging.concourse_rds_port
}

output "staging_concourse_rds_url" {
  value = module.concourse_staging.concourse_rds_url
}

output "staging_concourse_rds_username" {
  value = module.concourse_staging.concourse_rds_username
}

output "staging_concourse_rds_password" {
  value = module.concourse_staging.concourse_rds_password
  sensitive = true
}

output "staging_concourse_lb_target_group" {
  value = module.concourse_staging.concourse_lb_target_group
}

/* Production credhub */
output "production_credhub_subnet_az1" {
  value = module.credhub_production.credhub_subnet_az1
}

output "production_credhub_subnet_az2" {
  value = module.credhub_production.credhub_subnet_az2
}

output "production_credhub_subnet_az1_reserved" {
  value = "${cidrhost(module.credhub_production.credhub_subnet_cidr_az1, 0)} - ${cidrhost(module.credhub_production.credhub_subnet_cidr_az1, 3)}"
}

output "production_credhub_subnet_az2_reserved" {
  value = "${cidrhost(module.credhub_production.credhub_subnet_cidr_az2, 0)} - ${cidrhost(module.credhub_production.credhub_subnet_cidr_az2, 3)}"
}

output "production_credhub_subnet_cidr_az1" {
  value = module.credhub_production.credhub_subnet_cidr_az1
}

output "production_credhub_subnet_cidr_az2" {
  value = module.credhub_production.credhub_subnet_cidr_az2
}

output "production_credhub_subnet_az1_gateway" {
  value = cidrhost(module.credhub_production.credhub_subnet_cidr_az1, 1)
}

output "production_credhub_subnet_az2_gateway" {
  value = cidrhost(module.credhub_production.credhub_subnet_cidr_az2, 1)
}

output "production_credhub_security_group" {
  value = module.credhub_production.credhub_security_group
}

output "production_credhub_rds_identifier" {
  value = module.credhub_production.credhub_rds_identifier
}

output "production_credhub_rds_name" {
  value = module.credhub_production.credhub_rds_name
}

output "production_credhub_rds_host" {
  value = module.credhub_production.credhub_rds_host
}

output "production_credhub_rds_port" {
  value = module.credhub_production.credhub_rds_port
}

output "production_credhub_rds_url" {
  value = module.credhub_production.credhub_rds_url
}

output "production_credhub_rds_username" {
  value = module.credhub_production.credhub_rds_username
}

output "production_credhub_rds_password" {
  value = module.credhub_production.credhub_rds_password
  sensitive = true
}

output "production_credhub_lb_target_group" {
  value = module.credhub_production.credhub_lb_target_group
}

/* Staging credhub */
output "staging_credhub_subnet_az1" {
  value = module.credhub_staging.credhub_subnet_az1
}

output "staging_credhub_subnet_az2" {
  value = module.credhub_staging.credhub_subnet_az2
}

output "staging_credhub_subnet_az1_reserved" {
  value = "${cidrhost(module.credhub_staging.credhub_subnet_cidr_az1, 0)} - ${cidrhost(module.credhub_staging.credhub_subnet_cidr_az1, 3)}"
}

output "staging_credhub_subnet_az2_reserved" {
  value = "${cidrhost(module.credhub_staging.credhub_subnet_cidr_az2, 0)} - ${cidrhost(module.credhub_staging.credhub_subnet_cidr_az2, 3)}"
}


output "staging_credhub_subnet_cidr_az1" {
  value = module.credhub_staging.credhub_subnet_cidr_az1
}

output "staging_credhub_subnet_cidr_az2" {
  value = module.credhub_staging.credhub_subnet_cidr_az2
}


output "staging_credhub_subnet_az1_gateway" {
  value = cidrhost(module.credhub_staging.credhub_subnet_cidr_az1, 1)
}

output "staging_credhub_subnet_az2_gateway" {
  value = cidrhost(module.credhub_staging.credhub_subnet_cidr_az2, 1)
}

output "staging_credhub_security_group" {
  value = module.credhub_staging.credhub_security_group
}

output "staging_credhub_rds_identifier" {
  value = module.credhub_staging.credhub_rds_identifier
}

output "staging_credhub_rds_name" {
  value = module.credhub_staging.credhub_rds_name
}

output "staging_credhub_rds_host" {
  value = module.credhub_staging.credhub_rds_host
}

output "staging_credhub_rds_port" {
  value = module.credhub_staging.credhub_rds_port
}

output "staging_credhub_rds_url" {
  value = module.credhub_staging.credhub_rds_url
}

output "staging_credhub_rds_username" {
  value = module.credhub_staging.credhub_rds_username
}

output "staging_credhub_rds_password" {
  value = module.credhub_staging.credhub_rds_password
  sensitive = true
}

output "staging_credhub_lb_target_group" {
  value = module.credhub_staging.credhub_lb_target_group
}

/* Production Monitoring */
output "production_monitoring_az" {
  value = module.monitoring_production.monitoring_az
}

output "production_monitoring_subnet" {
  value = module.monitoring_production.monitoring_subnet
}

output "production_monitoring_security_group" {
  value = module.monitoring_production.monitoring_security_group
}

output "production_monitoring_lb_target_group" {
  value = module.monitoring_production.lb_target_group
}

output "production_doomsday_lb_target_group" {
  value = module.monitoring_production.doomsday_lb_target_group
}

output "monitoring_security_groups" {
  value = {
    staging     = module.monitoring_staging.monitoring_security_group
    development = module.monitoring_staging.monitoring_security_group
    production  = module.monitoring_production.monitoring_security_group
  }
}

/* Staging Monitoring */
output "staging_monitoring_az" {
  value = module.monitoring_staging.monitoring_az
}

output "staging_monitoring_subnet" {
  value = module.monitoring_staging.monitoring_subnet
}

output "staging_monitoring_security_group" {
  value = module.monitoring_staging.monitoring_security_group
}

output "staging_monitoring_lb_target_group" {
  value = module.monitoring_staging.lb_target_group
}

output "staging_doomsday_lb_target_group" {
  value = module.monitoring_staging.doomsday_lb_target_group
}

/* billing user */
output "billing_username" {
  value = module.billing_user.username
}

output "billing_access_key_id_prev" {
  value = module.billing_user.access_key_id_prev
}

output "billing_secret_access_key_prev" {
  value = module.billing_user.secret_access_key_prev
  sensitive = true
}

output "billing_access_key_id_curr" {
  value = module.billing_user.access_key_id_curr
}

output "billing_secret_access_key_curr" {
  value = module.billing_user.secret_access_key_curr
  sensitive = true
}

/* federalist auditor user */
output "federalist_auditor_username" {
  value = module.federalist_auditor_user.username
}

output "federalist_auditor_access_key_id_prev" {
  value = module.federalist_auditor_user.access_key_id_prev
}

output "federalist_auditor_secret_access_key_prev" {
  value = module.federalist_auditor_user.secret_access_key_prev
  sensitive = true
}

output "federalist_auditor_access_key_id_curr" {
  value = module.federalist_auditor_user.access_key_id_curr
}

output "federalist_auditor_secret_access_key_curr" {
  value = module.federalist_auditor_user.secret_access_key_curr
  sensitive = true
}

/* s3 logstash user */
output "s3_logstash_username" {
  value = module.s3_logstash.username
}

output "s3_logstash_access_key_id_prev" {
  value = module.s3_logstash.access_key_id_prev
}

output "s3_logstash_secret_access_key_prev" {
  value = module.s3_logstash.secret_access_key_prev
  sensitive = true
}

output "s3_logstash_access_key_id_curr" {
  value = module.s3_logstash.access_key_id_curr
}

output "s3_logstash_secret_access_key_curr" {
  value = module.s3_logstash.secret_access_key_curr
  sensitive = true
}

/* rds storage user */
output "rds_storage_alert_username" {
  value = module.rds_storage_alert.username
}

output "rds_storage_alert_access_key_id" {
  value = module.rds_storage_alert.access_key_id
}

output "rds_storage_alert_secret_access_key" {
  value = module.rds_storage_alert.secret_access_key
  sensitive = true
}

/* iam cert provision user */
output "iam_cert_provision_username" {
  value = module.iam_cert_provision_user.username
}

output "iam_cert_provision_access_key_id_prev" {
  value = module.iam_cert_provision_user.access_key_id_prev
}

output "iam_cert_provision_secret_access_key_prev" {
  value = module.iam_cert_provision_user.secret_access_key_prev
  sensitive = true
}

output "iam_cert_provision_access_key_id_curr" {
  value = module.iam_cert_provision_user.access_key_id_curr
}

output "iam_cert_provision_secret_access_key_curr" {
  value = module.iam_cert_provision_user.secret_access_key_curr
  sensitive = true
}

/* ecr user */
output "ecr_username" {
  value = module.ecr_user.username
}

output "ecr_access_key_id_prev" {
  value = module.ecr_user.access_key_id_prev
}

output "ecr_secret_access_key_prev" {
  value = module.ecr_user.secret_access_key_prev
  sensitive = true
}

output "ecr_access_key_id_curr" {
  value = module.ecr_user.access_key_id_curr
}

output "ecr_secret_access_key_curr" {
  value = module.ecr_user.secret_access_key_curr
  sensitive = true
}

/* iam roles */
output "default_profile" {
  value = module.default_role.profile_name
}

output "master_bosh_profile" {
  value = module.master_bosh_role.profile_name
}

output "bosh_profile" {
  value = module.bosh_role.profile_name
}

output "bosh_compilation_profile" {
  value = module.bosh_compilation_role.profile_name
}

output "concourse_worker_profile" {
  value = module.concourse_worker_role.profile_name
}

output "concourse_iaas_worker_profile" {
  value = module.concourse_iaas_worker_role.profile_name
}

/* nessus elb */
output "nessus_target_group" {
  value = aws_lb_target_group.nessus_target.name
}

output "nessus_static_ip" {
  value = cidrhost(module.stack.private_cidr_az1, 71)
}

/* BOSH UAA elb */
output "opsuaa_lb_dns_name" {
  value = aws_lb.opsuaa.dns_name
}

output "opsuaa_lb_name" {
  value = aws_lb.opsuaa.name
}

output "opsuaa_target_group" {
  value = aws_lb_target_group.opsuaa_target.name
}

/* DNS static IPs */
output "staging_dns_public_ips" {
  value = [aws_eip.staging_dns_eip.*.public_ip]
}

output "dns_axfr_security_group" {
  value = module.dns.axfr_security_group
}

output "dns_public_security_group" {
  value = module.dns.public_security_group
}

output "staging_dns_private_ips" {
  value = local.staging_dns_private_ips
}

output "production_dns_public_ips" {
  value = [aws_eip.production_dns_eip.*.public_ip]
}

output "production_dns_private_ips" {
  value = local.production_dns_private_ips
}

output "dns_private_ips" {
  value = concat(
    local.production_dns_private_ips,
    local.staging_dns_private_ips,
  )
}

/* Bucket names */
output "bosh_blobstore_bucket" {
  value = module.bosh_blobstore_bucket.bucket_name
}

output "buildpack_notify_state_staging_bucket_name" {
  value = module.buildpack_notify_state_staging.bucket_name
}

output "buildpack_notify_state_production_bucket_name" {
  value = module.buildpack_notify_state_production.bucket_name
}

/* smtp security group */
output "smtp_security_group" {
  value = module.smtp.smtp_security_group
}

output "production_smtp_private_ip" {
  value = local.production_smtp_private_ip
}


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

output "private_subnet_cidr_az1" {
  value = module.stack.private_cidr_az1
}

output "private_subnet_cidr_az2" {
  value = module.stack.private_cidr_az2
}

output "private_subnet_gateway_az1" {
  value = cidrhost(module.stack.private_cidr_az1, 1)
}

output "private_subnet_gateway_az2" {
  value = cidrhost(module.stack.private_cidr_az2, 1)
}

output "private_subnet_reserved_az1" {
  value = "${cidrhost(module.stack.private_cidr_az1, 0)} - ${cidrhost(module.stack.private_cidr_az1, 3)}"
}

output "private_subnet_reserved_az2" {
  value = "${cidrhost(module.stack.private_cidr_az2, 0)} - ${cidrhost(module.stack.private_cidr_az2, 3)}"
}

output "private_route_table_az1" {
  value = module.stack.private_route_table_az1
}

output "private_route_table_az2" {
  value = module.stack.private_route_table_az2
}

/* Public network */
output "public_subnet_az1" {
  value = module.stack.public_subnet_az1
}

output "public_subnet_az2" {
  value = module.stack.public_subnet_az2
}

output "public_subnet_cidr_az1" {
  value = module.stack.public_cidr_az1
}

output "public_subnet_cidr_az2" {
  value = module.stack.public_cidr_az2
}

output "public_subnet_gateway_az1" {
  value = cidrhost(module.stack.public_cidr_az1, 1)
}

output "public_subnet_gateway_az2" {
  value = cidrhost(module.stack.public_cidr_az2, 1)
}

output "public_subnet_reserved_az1" {
  value = "${cidrhost(module.stack.public_cidr_az1, 0)} - ${cidrhost(module.stack.public_cidr_az1, 3)}"
}

output "public_subnet_reserved_az2" {
  value = "${cidrhost(module.stack.public_cidr_az2, 0)} - ${cidrhost(module.stack.public_cidr_az2, 3)}"
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

/* Services network */
output "services_subnet_az1" {
  value = module.cf.services_subnet_az1
}

output "services_subnet_az2" {
  value = module.cf.services_subnet_az2
}

output "services_subnet_cidr_az1" {
  value = module.cf.services_cidr_1
}

output "services_subnet_cidr_az2" {
  value = module.cf.services_cidr_2
}

output "services_subnet_gateway_az1" {
  value = cidrhost(module.cf.services_cidr_1, 1)
}

output "services_subnet_gateway_az2" {
  value = cidrhost(module.cf.services_cidr_2, 1)
}

output "services_subnet_reserved_az1" {
  value = "${cidrhost(module.cf.services_cidr_1, 0)} - ${cidrhost(module.cf.services_cidr_1, 3)}"
}

output "services_subnet_reserved_az2" {
  value = "${cidrhost(module.cf.services_cidr_2, 0)} - ${cidrhost(module.cf.services_cidr_2, 3)}"
}

/* Per-deployment static IP ranges */
/* TODO: Make this go away */
data "template_file" "logsearch_static_ips" {
  count = 31
  vars = {
    address = cidrhost(module.cf.services_cidr_1, count.index + 20)
  }
  template = "$${address}"
}

output "logsearch_static_ips" {
  value = data.template_file.logsearch_static_ips.*.rendered
}

output "services_static_ips" {
  value = concat(
    data.template_file.logsearch_static_ips.*.rendered,
  )
}

/* Main LB */
output "main_lb_name" {
  value = aws_lb.main.name
}

output "main_lb_dns_name" {
  value = aws_lb.main.dns_name
}

/* CloudFoundry LB */
output "cf_lb_name" {
  value = module.cf.lb_name
}

output "cf_lb_dns_name" {
  value = module.cf.lb_dns_name
}

output "cf_apps_lb_name" {
  value = module.cf.apps_lb_name
}

output "cf_apps_lb_dns_name" {
  value = module.cf.apps_lb_dns_name
}

output "cf_uaa_lb_name" {
  value = module.cf.uaa_lb_name
}

output "cf_uaa_lb_dns_name" {
  value = module.cf.uaa_lb_dns_name
}

output "cf_router_target_groups" {
  value = concat(
    [module.cf.lb_target_https_group],
    [module.cf.apps_lb_target_https_group],
    [module.cf.uaa_lb_target_group],
    aws_lb_target_group.domains_broker_apps_https.*.name,
    aws_lb_target_group.domains_broker_challenge.*.name,
    aws_lb_target_group.domain_broker_v2_apps_https.*.name,
    aws_lb_target_group.domain_broker_v2_challenge.*.name,
  )
}

output "cf_target_group" {
  value = module.cf.lb_target_https_group
}

output "cf_apps_target_group" {
  value = module.cf.apps_lb_target_https_group
}

output "cf_uaa_target_group" {
  value = module.cf.uaa_lb_target_group
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

/* RDS Network */
output "rds_subnet_az1" {
  value = module.stack.rds_subnet_az1
}

output "rds_subnet_az2" {
  value = module.stack.rds_subnet_az2
}

output "rds_subnet_cidr_az1" {
  value = module.stack.rds_private_cidr_1
}

output "rds_subnet_cidr_az2" {
  value = module.stack.rds_private_cidr_2
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

/* Elasticache Network */
output "elasticache_subnet_az1" {
  value = module.elasticache_broker_network.elasticache_subnet_az1
}

output "elasticache_subnet_az2" {
  value = module.elasticache_broker_network.elasticache_subnet_az2
}

output "elasticache_subnet_cidr_az1" {
  value = module.elasticache_broker_network.elasticache_private_cidr_1
}

output "elasticache_subnet_cidr_az2" {
  value = module.elasticache_broker_network.elasticache_private_cidr_2
}

output "elasticache_subnet_group" {
  value = module.elasticache_broker_network.elasticache_subnet_group
}

output "elasticache_redis_security_group" {
  value = module.elasticache_broker_network.elasticache_redis_security_group
}

output "elasticache_broker_elb_name" {
  value = module.elasticache_broker_network.elasticache_elb_name
}

output "elasticache_broker_elb_dns_name" {
  value = module.elasticache_broker_network.elasticache_elb_dns_name
}

/* Elasticsearch Network */
output "elasticsearch_subnet_az1" {
  value = module.elasticsearch_broker.elasticsearch_subnet_az1
}

output "elasticsearch_subnet_az2" {
  value = module.elasticsearch_broker.elasticsearch_subnet_az2
}

output "elasticsearch_subnet_cidr_az1" {
  value = module.elasticsearch_broker.elasticsearch_private_cidr_1
}

output "elasticsearch_subnet_cidr_az2" {
  value = module.elasticsearch_broker.elasticsearch_private_cidr_2
}

output "elasticsearch_security_group" {
  value = module.elasticsearch_broker.elasticsearch_security_group
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
}

/* CloudFoundry RDS */
output "cf_rds_url" {
  value = module.cf.cf_rds_url
}

output "cf_rds_host" {
  value = module.cf.cf_rds_host
}

output "cf_rds_port" {
  value = module.cf.cf_rds_port
}

output "cf_rds_username" {
  value = module.cf.cf_rds_username
}

output "cf_rds_password" {
  value = module.cf.cf_rds_password
}

output "cf_rds_engine" {
  value = module.cf.cf_rds_engine
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
}

/* Diego ELB */
output "diego_elb_name" {
  value = module.diego.diego_elb_name
}

output "diego_elb_dns_name" {
  value = module.diego.diego_elb_dns_name
}

/* Logsearch network */
output "logsearch_elb_name" {
  value = module.logsearch.logsearch_elb_name
}

output "logsearch_elb_dns_name" {
  value = module.logsearch.logsearch_elb_dns_name
}

output "platform_syslog_elb_name" {
  value = module.logsearch.platform_syslog_elb_name
}

output "platform_syslog_elb_dns_name" {
  value = module.logsearch.platform_syslog_elb_dns_name
}

output "platform_kibana_lb_target_group" {
  value = module.logsearch.platform_kibana_lb_target_group
}

/* Shibboleth Proxy ELB */
output "shibboleth_lb_target_group" {
  value = module.shibboleth.shibboleth_lb_target_group
}

/* Admin UI ELB */
output "admin_lb_name" {
  value = module.admin.admin_lb_name
}

output "admin_lb_dns_name" {
  value = module.admin.admin_lb_dns_name
}

output "admin_lb_target_group" {
  value = module.admin.admin_lb_target_group
}

/* iam roles */
output "default_profile" {
  value = module.default_role.profile_name
}

output "bosh_profile" {
  value = module.bosh_role.profile_name
}

output "bosh_compilation_profile" {
  value = module.bosh_compilation_role.profile_name
}

output "logsearch_ingestor_profile" {
  value = module.logsearch_ingestor_role.profile_name
}

output "cf_blobstore_profile" {
  value = module.cf_blobstore_role.profile_name
}

output "elasticache_broker_profile" {
  value = module.elasticache_broker_role.profile_name
}

output "platform_profile" {
  value = module.platform_role.profile_name
}

output "upstream_bosh_compilation_profile" {
  value = data.terraform_remote_state.target_vpc.outputs.bosh_compilation_profile
}

output "external_domain_broker_gov_username" {
  value = module.external_domain_broker_govcloud.username
}

output "external_domain_broker_gov_access_key_id_curr" {
  value = module.external_domain_broker_govcloud.access_key_id_curr
}

output "external_domain_broker_gov_secret_access_key_curr" {
  value = module.external_domain_broker_govcloud.secret_access_key_curr
}

output "external_domain_broker_gov_access_key_id_prev" {
  value = module.external_domain_broker_govcloud.access_key_id_prev
}

output "external_domain_broker_gov_secret_access_key_prev" {
  value = module.external_domain_broker_govcloud.secret_access_key_prev
}

output "bosh_static_ip" {
  value = cidrhost(module.stack.private_cidr_az1, 7)
}

output "bosh_network_static_ips" {
  value = [
    cidrhost(module.stack.private_cidr_az1, 7),
  ]
}

/* Buckets */
output "logsearch_archive_bucket_name" {
  value = module.cf.logsearch_archive_bucket_name
}

output "bosh_blobstore_bucket" {
  value = module.bosh_blobstore_bucket.bucket_name
}

output "elb_log_bucket" {
  value = var.log_bucket_name
}

output "tooling_bosh_static_ip" {
  value = data.terraform_remote_state.target_vpc.outputs.tooling_bosh_static_ip
}

output "master_bosh_static_ip" {
  value = data.terraform_remote_state.target_vpc.outputs.master_bosh_static_ip
}

output "nessus_static_ip" {
  value = data.terraform_remote_state.target_vpc.outputs.nessus_static_ip
}

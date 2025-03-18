output "az1" {
  value = data.aws_availability_zones.available.names[var.az1_index]
}

output "az2" {
  value = data.aws_availability_zones.available.names[var.az2_index]
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
output "logsearch_static_ips" {
  value = [for i in range(0, 31) : cidrhost(module.cf.services_cidr_1, i + 20)]
}

output "services_static_ips" {
  value = concat(
    [for i in range(0, 31) : cidrhost(module.cf.services_cidr_1, i + 20)],
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
  value = flatten(concat(
    [module.cf.lb_target_https_group],
    [module.cf.apps_lb_target_https_group],
    [module.cf.lb_gr_target_https_group],
    [module.cf.apps_lb_gr_target_https_group],
    module.dedicated_loadbalancer_group.domains_lbgroup_target_group_apps_https_names,
    module.dedicated_loadbalancer_group.domains_lbgroup_target_group_gr_apps_https_names,
    aws_lb_target_group.domains_broker_apps_https.*.name,
    aws_lb_target_group.domains_broker_gr_apps_https.*.name,
    aws_lb_target_group.domains_broker_challenge.*.name,
  ))
}


output "cf_target_group" {
  value = module.cf.lb_target_https_group
}

output "cf_apps_target_group" {
  value = module.cf.apps_lb_target_https_group
}

/* Temp target groups */
output "cf_gr_target_group" {
  value = module.cf.lb_gr_target_https_group
}

output "cf_apps_gr_target_group" {
  value = module.cf.apps_lb_gr_target_https_group
}

output "cf_logstash_target_group" {
  value = flatten(concat(
    [module.cf.logstash_lb_target_https_group],
    [module.cf.logstash_gr_lb_target_https_group],
    module.dedicated_loadbalancer_group.domains_lbgroup_target_group_logstash_https_names,
    module.dedicated_loadbalancer_group.domains_lbgroup_target_group_gr_logstash_https_names,
    aws_lb_target_group.domains_broker_logstash_https.*.name,
    aws_lb_target_group.domains_broker_gr_logstash_https.*.name,
  ))
}

output "cf_uaa_target_group" {
  value = module.cf.uaa_lb_target_group
}

output "cf_router_main_target_group" {
  value = concat(
    [module.cf.uaa_lb_target_group],
    [module.cf.uaa_lb_gr_target_https_group],
  )
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

output "rds_subnet_az3" {
  value = module.stack.rds_subnet_az3
}

output "rds_subnet_az4" {
  value = module.stack.rds_subnet_az4
}


output "rds_subnet_cidr_az1" {
  value = module.stack.rds_private_cidr_1
}

output "rds_subnet_cidr_az2" {
  value = module.stack.rds_private_cidr_2
}

output "rds_subnet_cidr_az3" {
  value = module.stack.rds_private_cidr_3
}

output "rds_subnet_cidr_az4" {
  value = module.stack.rds_private_cidr_4
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
output "elasticsearch_log_group_audit" {
  value = module.elasticsearch_broker.elasticsearch_log_group_audit
}

output "elasticsearch_subnet1_az1" {
  value = module.elasticsearch_broker.elasticsearch_subnet1_az1
}

output "elasticsearch_subnet2_az2" {
  value = module.elasticsearch_broker.elasticsearch_subnet2_az2
}

output "elasticsearch_subnet3_az1" {
  value = module.elasticsearch_broker.elasticsearch_subnet3_az1
}

output "elasticsearch_subnet4_az2" {
  value = module.elasticsearch_broker.elasticsearch_subnet4_az2
}

output "elasticsearch_subnet_cidr_az1" {
  value = module.elasticsearch_broker.elasticsearch_private_cidr_1
}

output "elasticsearch_subnet_cidr_az2" {
  value = module.elasticsearch_broker.elasticsearch_private_cidr_2
}

output "elasticsearch_subnet_cidr_az3" {
  value = module.elasticsearch_broker.elasticsearch_private_cidr_3
}

output "elasticsearch_subnet_cidr_az4" {
  value = module.elasticsearch_broker.elasticsearch_private_cidr_4
}

output "elasticsearch_security_group" {
  value = module.elasticsearch_broker.elasticsearch_security_group
}

/* S3 Gateway Endpoint CIDRs for CF ASGs*/
output "s3_gateway_endpoint_cidrs" {
  value = data.aws_prefix_list.s3_gw_cidrs.cidr_blocks
}

/* s3 private gateway endpoint ips for public egress */
output "vpc_endpoint_customer_s3_if1_ip" {
  value = module.stack.vpc_endpoint_customer_s3_if1_ip
}

output "vpc_endpoint_customer_s3_if2_ip" {
  value = module.stack.vpc_endpoint_customer_s3_if2_ip
}

output "vpc_endpoint_customer_s3_dns" {
  value = module.stack.vpc_endpoint_customer_s3_dns
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
  value     = module.stack.bosh_rds_password
  sensitive = true
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
  value     = module.cf.cf_rds_password
  sensitive = true
}

output "cf_rds_engine" {
  value = module.cf.cf_rds_engine
}

/* CloudFoundry Autoscaler RDS */
output "cf_as_rds_url" {
  value = module.autoscaler.cf_as_rds_url
}

output "cf_as_rds_host" {
  value = module.autoscaler.cf_as_rds_host
}

output "cf_as_rds_port" {
  value = module.autoscaler.cf_as_rds_port
}

output "cf_as_rds_username" {
  value = module.autoscaler.cf_as_rds_username
}

output "cf_as_rds_password" {
  value     = module.autoscaler.cf_as_rds_password
  sensitive = true
}

output "cf_as_rds_engine" {
  value = module.autoscaler.cf_as_rds_engine
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
  value     = module.stack.credhub_rds_password
  sensitive = true
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

output "platform_logs_bucket_access_key_id_prev" {
  value = module.logsearch.platform_logs_bucket_access_key_id_prev
}

output "platform_logs_bucket_secret_access_key_prev" {
  value = module.logsearch.platform_logs_bucket_secret_access_key_prev
}

output "platform_logs_bucket_access_key_id_curr" {
  value = module.logsearch.platform_logs_bucket_access_key_id_curr
}

output "platform_logs_bucket_secret_access_key_curr" {
  value     = module.logsearch.platform_logs_bucket_secret_access_key_curr
  sensitive = true
}
output "platform_logs_bucket_name" {
  value = module.logsearch.platform_logs_bucket_name
}


/* Shibboleth Proxy ELB */
output "shibboleth_lb_target_group" {
  value = module.shibboleth.shibboleth_lb_target_group
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

output "logs_opensearch_ingestor_profile" {
  value = module.logs_opensearch_ingestor_role.profile_name
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
  value     = module.external_domain_broker_govcloud.secret_access_key_curr
  sensitive = true
}

output "external_domain_broker_gov_access_key_id_prev" {
  value = module.external_domain_broker_govcloud.access_key_id_prev
}

output "external_domain_broker_gov_secret_access_key_prev" {
  value     = module.external_domain_broker_govcloud.secret_access_key_prev
  sensitive = true
}

output "domains_dedicated_lbgroup_target_group_apps_https_names" {
  value = module.dedicated_loadbalancer_group.domains_lbgroup_target_group_apps_https_names
}

output "domains_dedicated_lbgroup_listener_arns" {
  value = module.dedicated_loadbalancer_group.domains_lbgroup_listener_arns
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

output "logs_opensearch_archive_bucket_name" {
  value = module.cf.logs_opensearch_archive_bucket_name
}

output "bosh_blobstore_bucket" {
  value = module.bosh_blobstore_bucket.bucket_name
}

output "elb_log_bucket" {
  value = module.log_bucket.elb_bucket_name
}

output "tooling_bosh_static_ip" {
  value = data.terraform_remote_state.target_vpc.outputs.tooling_bosh_static_ip
}

# master_bosh_static_ip kept for backwards compatability, is a duplicate of protobosh_static_ip
output "master_bosh_static_ip" {
  value = data.terraform_remote_state.target_vpc.outputs.master_bosh_static_ip
}


output "protobosh_static_ip" {
  value = data.terraform_remote_state.target_vpc.outputs.master_bosh_static_ip
}

output "nessus_static_ip" {
  value = data.terraform_remote_state.target_vpc.outputs.nessus_static_ip
}


output "s3_broker_user_access_key_id_prev" {
  value = ""
}

output "s3_broker_user_secret_access_key_prev" {
  value = ""
}

output "s3_broker_user_access_key_id_curr" {
  value = aws_iam_access_key.s3_broker_user_key_v1.id
}

output "s3_broker_user_secret_access_key_curr" {
  value     = aws_iam_access_key.s3_broker_user_key_v1.secret
  sensitive = true
}

output "default_key_name" {
  value = module.stack.default_key_name
}

output "tcp_lb_names" {
  value = module.cf.tcp_lb_names
}

output "tcp_lb_dns_names" {
  value = module.cf.tcp_lb_dns_names
}

output "tcp_lb_target_groups" {
  value = module.cf.tcp_lb_target_groups
}

output "tcp_lb_listener_ports" {
  value = module.cf.tcp_lb_listener_ports
}

output "tcp_lb_security_groups" {
  value = concat(module.cf.tcp_lb_security_groups.*.id, [module.stack.bosh_security_group])
}


output "csb" {
  description = "Values required to deploy the Cloud Service Broker and related services."
  sensitive   = true
  value = {
    iam = {
      csb = {
        access_key_id_curr     = module.csb_iam.csb_access_key_id_curr
        secret_access_key_curr = module.csb_iam.csb_secret_access_key_curr
        access_key_id_prev     = module.csb_iam.csb_access_key_id_prev
        secret_access_key_prev = module.csb_iam.csb_secret_access_key_prev
      }
      csb_helper = {
        access_key_id_curr     = module.csb_iam.csb_helper_access_key_id_curr
        secret_access_key_curr = module.csb_iam.csb_helper_secret_access_key_curr
        access_key_id_prev     = module.csb_iam.csb_helper_access_key_id_prev
        secret_access_key_prev = module.csb_iam.csb_helper_secret_access_key_prev
      }
      concourse = {
        access_key_id_curr     = module.csb_iam.concourse_access_key_id_curr
        secret_access_key_curr = module.csb_iam.concourse_secret_access_key_curr
        access_key_id_prev     = module.csb_iam.concourse_access_key_id_prev
        secret_access_key_prev = module.csb_iam.concourse_secret_access_key_prev
      }
      ecr = {
        access_key_id_curr     = module.csb_iam.ecr_access_key_id_curr
        secret_access_key_curr = module.csb_iam.ecr_secret_access_key_curr
        access_key_id_prev     = module.csb_iam.ecr_access_key_id_prev
        secret_access_key_prev = module.csb_iam.ecr_secret_access_key_prev
      }
    }
    rds = {
      # Use one() because broker module count is used to only create the module in dev. Once deployed in all environments and count is removed, this can be simplified.
      host     = one(module.csb_broker[*].rds_host)
      port     = one(module.csb_broker[*].rds_port)
      url      = one(module.csb_broker[*].rds_url)
      name     = one(module.csb_broker[*].rds_name)
      username = one(module.csb_broker[*].rds_username)
      password = one(module.csb_broker[*].rds_password)
    }
    notification_topics = {
      email_notification_topic_arn = module.sns.cg_platform_notifications_arn
      slack_notification_topic_arn = module.sns.cg_platform_slack_notifications_arn
    }
  }
}

output "opensearch_proxy_redis_cluster" {
  value = {
    host     = module.opensearch_proxy_redis_cluster.primary_endpoint
    password = module.opensearch_proxy_redis_cluster.password
  }
  sensitive = true
}

output "az1" {
  value = "${var.az1}"
}
output "az2" {
  value = "${var.az2}"
}
output "stack_description" {
  value = "${var.stack_description}"
}

/* VPC */
output "vpc_region" {
  value = "${var.aws_default_region}"
}
output "vpc_id" {
  value = "${module.stack.vpc_id}"
}
output "vpc_cidr" {
  value = "${module.stack.vpc_cidr}"
}
output "vpc_cidr_dns" {
  value = "${cidrhost("${module.stack.vpc_cidr}", 2)}"
}

/* Private network */
output "private_subnet_az1" {
  value = "${module.stack.private_subnet_az1}"
}
output "private_subnet_az2" {
  value = "${module.stack.private_subnet_az2}"
}
output "private_subnet_cidr_az1" {
  value = "${var.private_cidr_1}"
}
output "private_subnet_cidr_az2" {
  value = "${var.private_cidr_2}"
}
output "private_subnet_gateway_az1" {
  value = "${cidrhost("${var.private_cidr_1}", 1)}"
}
output "private_subnet_gateway_az2" {
  value = "${cidrhost("${var.private_cidr_2}", 1)}"
}
output "private_subnet_reserved_az1" {
  value = "${cidrhost("${var.private_cidr_1}", 0)} - ${cidrhost("${var.private_cidr_1}", 3)}"
}
output "private_subnet_reserved_az2" {
  value = "${cidrhost("${var.private_cidr_2}", 0)} - ${cidrhost("${var.private_cidr_2}", 3)}"
}
output "private_route_table_az1" {
  value = "${module.stack.private_route_table_az1}"
}
output "private_route_table_az2" {
  value = "${module.stack.private_route_table_az2}"
}

/* Public network */
output "public_subnet_az1" {
  value = "${module.stack.public_subnet_az1}"
}
output "public_subnet_az2" {
  value = "${module.stack.public_subnet_az2}"
}
output "public_subnet_cidr_az1" {
  value = "${var.public_cidr_1}"
}
output "public_subnet_cidr_az2" {
  value = "${var.public_cidr_2}"
}
output "public_subnet_gateway_az1" {
  value = "${cidrhost("${var.public_cidr_1}", 1)}"
}
output "public_subnet_gateway_az2" {
  value = "${cidrhost("${var.public_cidr_2}", 1)}"
}
output "public_subnet_reserved_az1" {
  value = "${cidrhost("${var.public_cidr_1}", 0)} - ${cidrhost("${var.public_cidr_1}", 3)}"
}
output "public_subnet_reserved_az2" {
  value = "${cidrhost("${var.public_cidr_2}", 0)} - ${cidrhost("${var.public_cidr_2}", 3)}"
}
output "public_route_table" {
  value = "${module.stack.public_route_table}"
}
output "nat_egress_ip_az1" {
  value = "${module.stack.nat_egress_ip_az1}"
}
output "nat_egress_ip_az2" {
  value = "${module.stack.nat_egress_ip_az2}"
}
output "nat_private_ip_az1" {
  value = "${module.stack.nat_private_ip_az1}"
}
output "nat_private_ip_az2" {
  value = "${module.stack.nat_private_ip_az2}"
}

/* Services network */
output "services_subnet_az1" {
  value = "${module.cf.services_subnet_az1}"
}
output "services_subnet_az2" {
  value = "${module.cf.services_subnet_az2}"
}
output "services_subnet_cidr_az1" {
  value = "${var.services_cidr_1}"
}
output "services_subnet_cidr_az2" {
  value = "${var.services_cidr_2}"
}
output "services_subnet_gateway_az1" {
  value = "${cidrhost("${var.services_cidr_1}", 1)}"
}
output "services_subnet_gateway_az2" {
  value = "${cidrhost("${var.services_cidr_2}", 1)}"
}
output "services_subnet_reserved_az1" {
  value = "${cidrhost("${var.services_cidr_1}", 0)} - ${cidrhost("${var.services_cidr_1}", 3)}"
}
output "services_subnet_reserved_az2" {
  value = "${cidrhost("${var.services_cidr_2}", 0)} - ${cidrhost("${var.services_cidr_2}", 3)}"
}

/* Per-deployment static IP ranges */
/* TODO: Make this go away */
data "template_file" "logsearch_static_ips" {
  count = 31
  vars {
    address = "${cidrhost("${var.services_cidr_1}", "${count.index + 20}")}"
  }
  template = "$${address}"
}
output "logsearch_static_ips" {
  value = ["${data.template_file.logsearch_static_ips.*.rendered}"]
}
data "template_file" "kubernetes_static_ips" {
  count = 31
  vars {
    address = "${cidrhost("${var.services_cidr_1}", "${count.index + 223}")}"
  }
  template = "$${address}"
}
output "kubernetes_static_ips" {
  value = ["${data.template_file.kubernetes_static_ips.*.rendered}"]
}


/* Security Groups */
output "bosh_security_group" {
  value = "${module.stack.bosh_security_group}"
}
output "local_vpc_traffic_security_group" {
    value = "${module.stack.local_vpc_traffic_security_group}"
}
output "web_traffic_security_group" {
  value = "${module.stack.web_traffic_security_group}"
}

/* RDS Network */
output "rds_subnet_az1" {
    value = "${module.stack.rds_subnet_az1}"
}
output "rds_subnet_az2" {
    value = "${module.stack.rds_subnet_az2}"
}
output "rds_subnet_cidr_az1" {
  value = "${var.rds_private_cidr_1}"
}
output "rds_subnet_cidr_az2" {
  value = "${var.rds_private_cidr_2}"
}
output "rds_subnet_group" {
    value = "${module.stack.rds_subnet_group}"
}
output "rds_mysql_security_group" {
  value = "${module.stack.rds_mysql_security_group}"
}
output "rds_postgres_security_group" {
  value = "${module.stack.rds_postgres_security_group}"
}
output "rds_mssql_security_group" {
  value = "${module.stack.rds_mssql_security_group}"
}
output "rds_oracle_security_group" {
  value = "${module.stack.rds_oracle_security_group}"
}

/* Elasticache Network */
output "elasticache_subnet_az1" {
  value = "${module.elasticache_broker_network.elasticache_subnet_az1}"
}
output "elasticache_subnet_az2" {
  value = "${module.elasticache_broker_network.elasticache_subnet_az2}"
}
output "elasticache_subnet_cidr_az1" {
  value = "${var.elasticache_private_cidr_1}"
}
output "elasticache_subnet_cidr_az2" {
  value = "${var.elasticache_private_cidr_2}"
}
output "elasticache_subnet_group" {
  value = "${module.elasticache_broker_network.elasticache_subnet_group}"
}
output "elasticache_redis_security_group" {
  value = "${module.elasticache_broker_network.elasticache_redis_security_group}"
}
output "elasticache_broker_elb_name" {
  value = "${module.elasticache_broker_network.elasticache_elb_name}"
}
output "elasticache_broker_elb_dns_name" {
  value = "${module.elasticache_broker_network.elasticache_elb_dns_name}"
}

/* RDS Bosh Instance */
output "bosh_rds_url_curr" {
  value = "${module.stack.bosh_rds_url_curr}"
}
output "bosh_rds_host_curr" {
  value = "${module.stack.bosh_rds_host_curr}"
}
output "bosh_rds_url_prev" {
  value = "${module.stack.bosh_rds_url_prev}"
}
output "bosh_rds_host_prev" {
  value = "${module.stack.bosh_rds_host_prev}"
}
output "bosh_rds_port" {
  value = "${module.stack.bosh_rds_port}"
}
output "bosh_rds_username" {
  value = "${module.stack.bosh_rds_username}"
}
output "bosh_rds_password" {
  value = "${module.stack.bosh_rds_password}"
}

/* CloudFoundry ELBs */
output "cf_main_elb_dns_name" {
  value = "${module.cf.elb_main_dns_name}"
}
output "cf_main_elb_name" {
  value = "${module.cf.elb_main_name}"
}
output "cf_logging_elb_dns_name" {
  value = "${module.cf.elb_logging_dns_name}"
}
output "cf_logging_elb_name" {
  value = "${module.cf.elb_logging_name}"
}
output "cf_apps_elb_dns_name" {
  value = "${module.cf.elb_apps_dns_name}"
}
output "cf_apps_elb_name" {
  value = "${module.cf.elb_apps_name}"
}

/* CloudFoundry RDS */
output "cf_rds_url" {
  value = "${module.cf.cf_rds_url}"
}
output "cf_rds_host" {
  value = "${module.cf.cf_rds_host}"
}
output "cf_rds_port" {
  value = "${module.cf.cf_rds_port}"
}
output "cf_rds_username" {
  value = "${module.cf.cf_rds_username}"
}
output "cf_rds_password" {
  value = "${module.cf.cf_rds_password}"
}
output "cf_rds_engine" {
  value = "${module.cf.cf_rds_engine}"
}

/* Diego ELB */
output "diego_elb_name" {
  value = "${module.diego.diego_elb_name}"
}

output "diego_elb_dns_name" {
  value = "${module.diego.diego_elb_dns_name}"
}

/* Kubernetes network */
output "kubernetes_elb_name" {
  value = "${module.kubernetes.kubernetes_elb_name}"
}
output "kubernetes_elb_dns_name" {
  value = "${module.kubernetes.kubernetes_elb_dns_name}"
}
output "kubernetes_elb_security_group" {
  value = "${module.kubernetes.kubernetes_elb_security_group}"
}
output "kubernetes_ec2_security_group" {
  value = "${module.kubernetes.kubernetes_ec2_security_group}"
}

/* Logsearch network */
output "logsearch_elb_name" {
  value = "${module.logsearch.logsearch_elb_name}"
}
output "logsearch_elb_dns_name" {
  value = "${module.logsearch.logsearch_elb_dns_name}"
}

output "platform_syslog_elb_name" {
  value = "${module.logsearch.platform_syslog_elb_name}"
}
output "platform_syslog_elb_dns_name" {
  value = "${module.logsearch.platform_syslog_elb_dns_name}"
}

output "platform_kibana_elb_name" {
  value = "${module.logsearch.platform_kibana_elb_name}"
}
output "platform_kibana_elb_dns_name" {
  value = "${module.logsearch.platform_kibana_elb_dns_name}"
}

/* Client ELBs */
output "star_18f_gov_elb_name" {
  value = "${module.client-elbs.star_18f_gov_elb_name}"
}

output "star_18f_gov_elb_dns_name" {
  value = "${module.client-elbs.star_18f_gov_elb_dns_name}"
}

/* Shibboleth Proxy ELB */
output "shibboleth_elb_name" {
  value = "${module.shibboleth.shibboleth_elb_name}"
}

output "shibboleth_elb_dns_name" {
  value = "${module.shibboleth.shibboleth_elb_dns_name}"
}

output "shibboleth_elb_zone_id" {
  value = "${module.shibboleth.shibboleth_elb_zone_id}"
}

/* Concourse */
output "concourse_subnet" {
  value = "${module.concourse.concourse_subnet}"
}
output "concourse_subnet_cidr" {
  value = "${module.concourse.concourse_subnet_cidr}"
}
output "concourse_subnet_gateway" {
  value = "${cidrhost("${module.concourse.concourse_subnet_cidr}", 1)}"
}
output "concourse_subnet_reserved" {
  value = "${cidrhost("${module.concourse.concourse_subnet_cidr}", 0)} - ${cidrhost("${module.concourse.concourse_subnet_cidr}", 3)}"
}
output "concourse_security_group" {
  value = "${module.concourse.concourse_security_group}"
}
output "concourse_rds_identifier" {
  value = "${module.concourse.concourse_rds_identifier}"
}
output "concourse_rds_name" {
  value = "${module.concourse.concourse_rds_name}"
}
output "concourse_rds_host" {
  value = "${module.concourse.concourse_rds_host}"
}
output "concourse_rds_port" {
  value = "${module.concourse.concourse_rds_port}"
}
output "concourse_rds_url" {
  value = "${module.concourse.concourse_rds_url}"
}
output "concourse_rds_username" {
  value = "${module.concourse.concourse_rds_username}"
}
output "concourse_rds_password" {
  value = "${module.concourse.concourse_rds_password}"
}
output "concourse_elb_dns_name" {
  value = "${module.concourse.concourse_elb_dns_name}"
}
output "concourse_elb_name" {
  value = "${module.concourse.concourse_elb_name}"
}
output "concourse_elb_zone_id" {
  value = "${module.concourse.concourse_elb_zone_id}"
}

/* iam roles */
output "default_profile" {
  value = "${module.default_role.profile_name}"
}
output "bosh_profile" {
  value = "${module.bosh_role.profile_name}"
}
output "bosh_compilation_profile" {
  value = "${module.bosh_compilation_role.profile_name}"
}
output "logsearch_ingestor_profile" {
  value = "${module.logsearch_ingestor_role.profile_name}"
}
output "kubernetes_master_profile" {
  value = "${module.kubernetes_master_role.profile_name}"
}
output "kubernetes_minion_profile" {
  value = "${module.kubernetes_minion_role.profile_name}"
}
output "kubernetes_node_profile" {
  value = "${module.kubernetes_node_role.profile_name}"
}
output "kubernetes_logger_profile" {
  value = "${module.kubernetes_logger_role.profile_name}"
}
output "etcd_backup_profile" {
  value = "${module.etcd_backup_role.profile_name}"
}
output "cf_blobstore_profile" {
  value = "${module.cf_blobstore_role.profile_name}"
}
output "elasticache_broker_profile" {
  value = "${module.elasticache_broker_role.profile_name}"
}
output "platform_profile" {
  value = "${module.platform_role.profile_name}"
}

output "upstream_bosh_compilation_profile" {
  value = "${data.terraform_remote_state.target_vpc.bosh_compilation_profile}"
}

output "bosh_static_ip" {
  value = "${cidrhost("${var.private_cidr_1}", 7)}"
}
output "bosh_uaa_static_ips" {
  value = [
    "${cidrhost("${var.private_cidr_1}", 4)}"
  ]
}

/* Buckets */
output "logsearch_archive_bucket_name" {
  value = "${module.cf.logsearch_archive_bucket_name}"
}
output "etcd_backup_bucket_name" {
  value = "${module.cf.etcd_backup_bucket_name}"
}

output "tooling_bosh_static_ip" {
  value = "${data.terraform_remote_state.target_vpc.tooling_bosh_static_ip}"
}
output "master_bosh_static_ip" {
  value = "${data.terraform_remote_state.target_vpc.master_bosh_static_ip}"
}

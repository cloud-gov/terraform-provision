
/* VPC */
output "vpc_id" {
    value = "${module.stack.vpc_id}"
}
output "vpc_cidr" {
    value = "${module.stack.vpc_cidr}"
}

/* Private network */
output "private_subnet_az1" {
  value = "${module.stack.private_subnet_az1}"
}
output "private_subnet_az2" {
  value = "${module.stack.private_subnet_az2}"
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
output "public_route_table" {
  value = "${module.stack.public_route_table}"
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
output "rds_subnet_group" {
    value = "${module.stack.rds_subnet_group}"
}
output "rds_mysql_security_group" {
  value = "${module.stack.rds_mysql_security_group}"
}
output "rds_postgres_security_group" {
  value = "${module.stack.rds_postgres_security_group}"
}

/* RDS Bosh Instance */
output "bosh_rds_url" {
  value = "${module.stack.bosh_rds_url}"
}
output "bosh_rds_host" {
  value = "${module.stack.bosh_rds_host}"
}
output "bosh_rds_port" {
  value = "${module.stack.bosh_rds_port}"
}

/* bosh user */
output "bosh_username" {
  value = "${module.stack.bosh_username}"
}
output "bosh_access_key_id" {
  value = "${module.stack.bosh_access_key_id}"
}
output "bosh_secret_access_key" {
  value = "${module.stack.bosh_secret_access_key}"
}

/* CloudFoundry ELBs */
output "cf_main_elb_dns_name" {
  value = "${module.cf.elb_main_dns_name}"
}
output "cf_main_elb_name" {
  value = "${module.cf.elb_main_name}"
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

/* Services Subnets */
output "services_subnet_az1" {
  value = "${module.cf.services_subnet_az1}"
}
output "services_subnet_az2" {
  value = "${module.cf.services_subnet_az2}"
}

/* Diego ELB */
output "diego_elb_name" {
  value = "${module.diego.diego_elb_name}"
}

output "diego_elb_dns_name" {
  value = "${module.diego.diego_elb_dns_name}"
}

/* Diego subnets */
output "diego_services_subnet_az1" {
  value = "${module.diego.diego_services_subnet_az1}"
}
output "diego_services_subnet_az2" {
  value = "${module.diego.diego_services_subnet_az2}"
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

/* S3 broker user */
output "s3_broker_username" {
  value = "${module.cf.s3_broker_username}"
}
output "s3_broker_access_key_id" {
  value = "${module.cf.s3_broker_access_key_id}"
}
output "s3_broker_secret_access_key" {
  value = "${module.cf.s3_broker_secret_access_key}"
}

/* Client ELBs */

output "client_elb_star_18f_gov_name" {
  value = "${module.client-elbs.star_18f_gov_elb_name}"
}

output "client_elb_star_18f_gov_dsn_name" {
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
output "concourse_security_group" {
  value = "${module.concourse.concourse_security_group}"
}
output "concourse_rds_url" {
  value = "${module.concourse.concourse_rds_url}"
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
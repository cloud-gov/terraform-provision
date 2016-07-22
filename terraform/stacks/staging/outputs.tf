
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

output "monitoring_elb_dns_name" {
  value = "${module.cf.monitoring_elb_dns_name}"
}
output "monitoring_elb_name" {
  value = "${module.cf.monitoring_elb_name}"
}
output "monitoring_elb_security_group" {
  value = "${module.cf.monitoring_elb_security_group}"
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
  value = "${module.diego.diego_az1_services}"
}
output "diego_services_subnet_az2" {
  value = "${module.diego.diego_az2_services}"
}




/* VPC */
output "vpc_id" {
    value = "${module.base.vpc_id}"
}
output "vpc_cidr" {
    value = "${module.base.vpc_cidr}"
}

output "tooling_vpc_id" {
    value = "${data.terraform_remote_state.target_vpc.vpc_id}"
}
output "tooling_vpc_cidr" {
    value = "${data.terraform_remote_state.target_vpc.vpc_cidr}"
}

/* Private network */
output "private_subnet_az1" {
  value = "${module.base.private_subnet_az1}"
}
output "private_subnet_az2" {
  value = "${module.base.private_subnet_az2}"
}
output "private_route_table_az1" {
  value = "${module.base.private_route_table_az1}"
}
output "private_route_table_az2" {
  value = "${module.base.private_route_table_az2}"
}

/* Public network */
output "public_subnet_az1" {
  value = "${module.base.public_subnet_az1}"
}
output "public_subnet_az2" {
  value = "${module.base.public_subnet_az2}"
}
output "public_route_table" {
  value = "${module.base.public_route_table}"
}

/* Security Groups */
output "bosh_security_group" {
  value = "${module.base.bosh_security_group}"
}
output "local_vpc_traffic_security_group" {
    value = "${module.base.local_vpc_traffic_security_group}"
}
output "web_traffic_security_group" {
  value = "${module.base.web_traffic_security_group}"
}
output "restricted_web_traffic_security_group" {
  value = "${module.base.restricted_web_traffic_security_group}"
}


/* RDS Network */
output "rds_subnet_az1" {
    value = "${module.base.rds_subnet_az1}"
}
output "rds_subnet_az2" {
    value = "${module.base.rds_subnet_az2}"
}
output "rds_subnet_group" {
    value = "${module.base.rds_subnet_group}"
}
output "rds_mysql_security_group" {
  value = "${module.base.rds_mysql_security_group}"
}
output "rds_postgres_security_group" {
  value = "${module.base.rds_postgres_security_group}"
}

/* RDS Bosh Instance */
output "bosh_rds_url" {
  value = "${module.base.bosh_rds_url}"
}
output "bosh_rds_host" {
  value = "${module.base.bosh_rds_host}"
}
output "bosh_rds_port" {
  value = "${module.base.bosh_rds_port}"
}

/* bosh user */
output "bosh_username" {
  value = "${module.bosh_user.username}"
}
output "bosh_access_key_id" {
  value = "${module.bosh_user.access_key_id}"
}
output "bosh_secret_access_key" {
  value = "${module.bosh_user.secret_access_key}"
}

/* Shibboleth ELB */

output "shibboleth_elb_name" {
  value ="${module.shibboleth.shibboleth_elb_name}"
}

output "shibboleth_elb_dns_name" {
  value = "${module.shibboleth.shibboleth_elb_dns_name}"
}

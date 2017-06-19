/* VPC */
output "vpc_id" {
    value = "${module.base.vpc_id}"
}
output "vpc_cidr" {
    value = "${module.base.vpc_cidr}"
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

output "nat_egress_ip_az1" {
  value = "${module.base.nat_egress_ip_az1}"
}

output "nat_egress_ip_az2" {
  value = "${module.base.nat_egress_ip_az2}"
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
output "rds_mssql_security_group" {
  value = "${module.base.rds_mssql_security_group}"
}
output "rds_oracle_security_group" {
  value = "${module.base.rds_oracle_security_group}"
}

/* RDS Bosh Instance */
output "bosh_rds_url_curr" {
  value = "${module.base.bosh_rds_url_curr}"
}
output "bosh_rds_host_curr" {
  value = "${module.base.bosh_rds_host_curr}"
}
output "bosh_rds_url_prev" {
  value = "${module.base.bosh_rds_url_prev}"
}
output "bosh_rds_host_prev" {
  value = "${module.base.bosh_rds_host_prev}"
}
output "bosh_rds_port" {
  value = "${module.base.bosh_rds_port}"
}
output "bosh_rds_username" {
  value = "${module.base.bosh_rds_username}"
}
output "bosh_rds_password" {
  value = "${module.base.bosh_rds_password}"
}


/* VPC */
output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}
output "vpc_cidr" {
    value = "${module.vpc.vpc_cidr}"
}

/* Private network */
output "private_subnet_az1" {
  value = "${module.vpc.private_subnet_az1}"
}
output "private_subnet_az2" {
  value = "${module.vpc.private_subnet_az2}"
}
output "private_route_table_az1" {
  value = "${module.vpc.private_route_table_az1}"
}
output "private_route_table_az2" {
  value = "${module.vpc.private_route_table_az2}"
}

/* Public network */
output "public_subnet_az1" {
  value = "${module.vpc.public_subnet_az1}"
}
output "public_subnet_az2" {
  value = "${module.vpc.public_subnet_az2}"
}
output "public_route_table" {
  value = "${module.vpc.public_route_table}"
}

output "az1_egress_ip" {
  value = "${module.vpc.az1_egress_ip}"
}

output "az2_egress_ip" {
  value = "${module.vpc.az2_egress_ip}"
}

/* Security Groups */
output "bosh_security_group" {
  value = "${module.vpc.bosh_security_group}"
}
output "local_vpc_traffic_security_group" {
    value = "${module.vpc.local_vpc_traffic_security_group}"
}
output "web_traffic_security_group" {
  value = "${module.vpc.web_traffic_security_group}"
}
output "restricted_web_traffic_security_group" {
  value = "${module.vpc.restricted_web_traffic_security_group}"
}

/* RDS Network */
output "rds_subnet_az1" {
    value = "${module.rds_network.rds_subnet_az1}"
}
output "rds_subnet_az2" {
    value = "${module.rds_network.rds_subnet_az2}"
}
output "rds_subnet_group" {
    value = "${module.rds_network.rds_subnet_group}"
}
output "rds_mysql_security_group" {
  value = "${module.rds_network.rds_mysql_security_group}"
}
output "rds_postgres_security_group" {
  value = "${module.rds_network.rds_postgres_security_group}"
}

/* RDS Bosh Instance */
output "bosh_rds_url_curr" {
  value = "${module.rds.rds_url}"
}
output "bosh_rds_host_curr" {
  value = "${module.rds.rds_host}"
}
output "bosh_rds_url_prev" {
  value = ""
}
output "bosh_rds_host_prev" {
  value = ""
}
output "bosh_rds_port" {
  value = "${module.rds.rds_port}"
}
output "bosh_rds_username" {
  value = "${module.rds.rds_username}"
}
output "bosh_rds_password" {
  value = "${module.rds.rds_password}"
}

/* VPC */
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

/* Private network */
output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "private_cidrs" {
  value = module.vpc.private_cidrs
}

output "vpc_endpoint_customer_s3_ips" {
  value = module.vpc.vpc_endpoint_customer_s3_if_ips
}

output "vpc_endpoint_customer_s3_dns" {
  value = module.vpc.vpc_endpoint_customer_s3_dns
}

/* Public network */
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "public_cidrs" {
  value = module.vpc.public_cidrs
}

output "nat_egress_ips" {
  value = module.vpc.nat_egress_ips
}

/* Security Groups */
output "bosh_security_group" {
  value = module.vpc.bosh_security_group
}

output "local_vpc_traffic_security_group" {
  value = module.vpc.local_vpc_traffic_security_group
}

output "web_traffic_security_group" {
  value = module.vpc.web_traffic_security_group
}

output "restricted_web_traffic_security_group" {
  value = module.vpc.restricted_web_traffic_security_group
}

/* RDS Network */
output "rds_subnet_ids" {
  value = module.rds_network.rds_subnet_ids
}

output "rds_private_cidrs" {
  value = module.rds_network.rds_private_cidrs
}

output "rds_subnet_group" {
  value = module.rds_network.rds_subnet_group
}

output "rds_mysql_security_group" {
  value = module.rds_network.rds_mysql_security_group
}

output "rds_postgres_security_group" {
  value = module.rds_network.rds_postgres_security_group
}

output "rds_mssql_security_group" {
  value = module.rds_network.rds_mssql_security_group
}

output "rds_oracle_security_group" {
  value = module.rds_network.rds_oracle_security_group
}

/* RDS Bosh Instance */
output "bosh_rds_url_curr" {
  value = module.rds.rds_url
}

output "bosh_rds_host_curr" {
  value = module.rds.rds_host
}

output "bosh_rds_url_prev" {
  value = ""
}

output "bosh_rds_host_prev" {
  value = ""
}

output "bosh_rds_port" {
  value = module.rds.rds_port
}

output "bosh_rds_username" {
  value = module.rds.rds_username
}

output "bosh_rds_password" {
  value     = module.rds.rds_password
  sensitive = true
}

/*
 * CredHub RDS Instance
 */

output "credhub_rds_identifier" {
  value = module.credhub_rds.rds_identifier
}

output "credhub_rds_name" {
  value = module.credhub_rds.rds_name
}

output "credhub_rds_host" {
  value = module.credhub_rds.rds_host
}

output "credhub_rds_port" {
  value = module.credhub_rds.rds_port
}

output "credhub_rds_url" {
  value = module.credhub_rds.rds_url
}

output "credhub_rds_username" {
  value = module.credhub_rds.rds_username
}

output "credhub_rds_password" {
  value     = module.credhub_rds.rds_password
  sensitive = true
}

output "default_key_name" {
  value = module.vpc.default_key_name
}

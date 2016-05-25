/*
 * ----------------------------------------------------------
 *
 *    Tooling stack
 *
 * ----------------------------------------------------------
 *
 */
/* VPC */
output "tooling_vpc_id" {
    value = "${module.tooling_stack.vpc_id}"
}
output "tooling_vpc_cidr" {
    value = "${module.tooling_stack.vpc_cidr}"
}

/* Private network */
output "tooling_private_subnet_az1" {
  value = "${module.tooling_stack.private_subnet_az1}"
}
output "tooling_private_subnet_az2" {
  value = "${module.tooling_stack.private_subnet_az2}"
}
output "tooling_private_route_table_az1" {
  value = "${module.tooling_stack.private_route_table_az1}"
}
output "tooling_private_route_table_az2" {
  value = "${module.tooling_stack.private_route_table_az2}"
}

/* Public network */
output "tooling_public_subnet_az1" {
  value = "${module.tooling_stack.public_subnet_az1}"
}
output "tooling_public_subnet_az2" {
  value = "${module.tooling_stack.public_subnet_az2}"
}
output "tooling_public_route_table" {
  value = "${module.tooling_stack.public_route_table}"
}

/* Security Groups */
output "tooling_bosh_security_group" {
  value = "${module.tooling_stack.bosh_security_group}"
}
output "tooling_local_vpc_traffic_security_group" {
    value = "${module.tooling_stack.local_vpc_traffic_security_group}"
}
output "tooling_web_traffic_security_group" {
  value = "${module.tooling_stack.web_traffic_security_group}"
}

/* RDS Network */
output "tooling_rds_subnet_az1" {
    value = "${module.tooling_stack.rds_subnet_az1}"
}
output "tooling_rds_subnet_az2" {
    value = "${module.tooling_stack.rds_subnet_az2}"
}
output "tooling_rds_subnet_group" {
    value = "${module.tooling_stack.rds_subnet_group}"
}
output "tooling_rds_mysql_security_group" {
  value = "${module.tooling_stack.rds_mysql_security_group}"
}
output "tooling_rds_postgres_security_group" {
  value = "${module.tooling_stack.rds_postgres_security_group}"
}

/* RDS Bosh Instance */
output "tooling_bosh_rds_url" {
  value = "${module.tooling_stack.bosh_rds_url}"
}


/* Production Concourse */
output "production_concourse_subnet" {
  value = "${module.tooling_stack.production_concourse_subnet}"
}
output "production_concourse_security_group" {
  value = "${module.tooling_stack.production_concourse_security_group}"
}
output "production_concourse_rds_url" {
  value = "${module.tooling_stack.production_concourse_rds_url}"
}
output "production_concourse_elb_dns_name" {
  value = "${module.tooling_stack.production_concourse_elb_dns_name}"
}


/* Staging Concourse */
output "staging_concourse_subnet" {
  value = "${module.tooling_stack.staging_concourse_subnet}"
}
output "staging_concourse_security_group" {
  value = "${module.tooling_stack.staging_concourse_security_group}"
}
output "staging_concourse_rds_url" {
  value = "${module.tooling_stack.staging_concourse_rds_url}"
}
output "staging_concourse_elb_dns_name" {
  value = "${module.tooling_stack.staging_concourse_elb_dns_name}"
}

/*
 * ----------------------------------------------------------
 *
 *    Production stack
 *
 * ----------------------------------------------------------
 *
 */
 /* VPC */
output "production_vpc_id" {
    value = "${module.production_stack.vpc_id}"
}
output "production_vpc_cidr" {
    value = "${module.production_stack.vpc_cidr}"
}

/* Private network */
output "production_private_subnet_az1" {
  value = "${module.production_stack.private_subnet_az1}"
}
output "production_private_subnet_az2" {
  value = "${module.production_stack.private_subnet_az2}"
}
output "production_private_route_table_az1" {
  value = "${module.production_stack.private_route_table_az1}"
}
output "production_private_route_table_az2" {
  value = "${module.production_stack.private_route_table_az2}"
}

/* Public network */
output "production_public_subnet_az1" {
  value = "${module.production_stack.public_subnet_az1}"
}
output "production_public_subnet_az2" {
  value = "${module.production_stack.public_subnet_az2}"
}
output "production_public_route_table" {
  value = "${module.production_stack.public_route_table}"
}

/* Security Groups */
output "production_bosh_security_group" {
  value = "${module.production_stack.bosh_security_group}"
}
output "production_local_vpc_traffic_security_group" {
    value = "${module.production_stack.local_vpc_traffic_security_group}"
}
output "production_web_traffic_security_group" {
  value = "${module.production_stack.web_traffic_security_group}"
}

/* RDS Network */
output "production_rds_subnet_az1" {
    value = "${module.production_stack.rds_subnet_az1}"
}
output "production_rds_subnet_az2" {
    value = "${module.production_stack.rds_subnet_az2}"
}
output "production_rds_subnet_group" {
    value = "${module.production_stack.rds_subnet_group}"
}
output "production_rds_mysql_security_group" {
  value = "${module.production_stack.rds_mysql_security_group}"
}
output "production_rds_postgres_security_group" {
  value = "${module.production_stack.rds_postgres_security_group}"
}

/* RDS Bosh Instance */
output "production_bosh_rds_url" {
  value = "${module.production_stack.bosh_rds_url}"
}


/*
 * ----------------------------------------------------------
 *
 *    staging stack
 *
 * ----------------------------------------------------------
 *
 */
 /* VPC */
output "staging_vpc_id" {
    value = "${module.staging_stack.vpc_id}"
}
output "staging_vpc_cidr" {
    value = "${module.staging_stack.vpc_cidr}"
}

/* Private network */
output "staging_private_subnet_az1" {
  value = "${module.staging_stack.private_subnet_az1}"
}
output "staging_private_subnet_az2" {
  value = "${module.staging_stack.private_subnet_az2}"
}
output "staging_private_route_table_az1" {
  value = "${module.staging_stack.private_route_table_az1}"
}
output "staging_private_route_table_az2" {
  value = "${module.staging_stack.private_route_table_az2}"
}

/* Public network */
output "staging_public_subnet_az1" {
  value = "${module.staging_stack.public_subnet_az1}"
}
output "staging_public_subnet_az2" {
  value = "${module.staging_stack.public_subnet_az2}"
}
output "staging_public_route_table" {
  value = "${module.staging_stack.public_route_table}"
}

/* Security Groups */
output "staging_bosh_security_group" {
  value = "${module.staging_stack.bosh_security_group}"
}
output "staging_local_vpc_traffic_security_group" {
    value = "${module.staging_stack.local_vpc_traffic_security_group}"
}
output "staging_web_traffic_security_group" {
  value = "${module.staging_stack.web_traffic_security_group}"
}

/* RDS Network */
output "staging_rds_subnet_az1" {
    value = "${module.staging_stack.rds_subnet_az1}"
}
output "staging_rds_subnet_az2" {
    value = "${module.staging_stack.rds_subnet_az2}"
}
output "staging_rds_subnet_group" {
    value = "${module.staging_stack.rds_subnet_group}"
}
output "staging_rds_mysql_security_group" {
  value = "${module.staging_stack.rds_mysql_security_group}"
}
output "staging_rds_postgres_security_group" {
  value = "${module.staging_stack.rds_postgres_security_group}"
}

/* RDS Bosh Instance */
output "staging_bosh_rds_url" {
  value = "${module.staging_stack.bosh_rds_url}"
}
/*
 * Tooling stack
 *
 * This stack relies on defaults heavily. Please look through
 * all the module sources, and specifically, the variables.tf
 * in each module, which declares these defaults.
 */

module "vpc" {
    source = "../../modules/bosh_vpc"
}

module "rds_network" {
    source = "../../modules/rds_network"

    vpc_id = "${module.vpc.vpc_id}"
}

module "rds" {
    source = "../../modules/rds"
    rds_password = "${var.rds_password}"
    rds_subnet_group = "${module.rds_network.rds_subnet_group}"
    rds_security_groups = "${module.rds_network.rds_postgres_security_group},${module.rds_network.rds_mysql_security_group}"
}

module "concourse_production" {
  source = "../../modules/concourse"
    vpc_id = "${module.vpc.vpc_id}"
    concourse_cidr = "${var.concourse_prod_cidr}"
    concourse_az = "${var.concourse_prod_az}"
    route_table_id = "${module.vpc.private_route_table_az1}"
    rds_password = "${var.concourse_prod_rds_password}"
    rds_subnet_group = "${module.rds_network.rds_subnet_group}"
    rds_security_groups = "${module.rds_network.rds_postgres_security_group},${module.rds_network.rds_mysql_security_group}"
    account_id = "${var.account_id}"
    elb_cert_name = "${var.concourse_prod_elb_cert_name}"
    elb_subnets = "${module.vpc.public_subnet_az1}"
    elb_security_groups = "${module.vpc.web_traffic_security_group}"
}

module "concourse_staging" {
  source = "../../modules/concourse"
    vpc_id = "${module.vpc.vpc_id}"
    concourse_cidr = "${var.concourse_staging_cidr}"
    concourse_az = "${var.concourse_staging_az}"
    route_table_id = "${module.vpc.private_route_table_az2}"
    rds_password = "${var.concourse_staging_rds_password}"
    rds_subnet_group = "${module.rds_network.rds_subnet_group}"
    rds_security_groups = "${module.rds_network.rds_postgres_security_group},${module.rds_network.rds_mysql_security_group}"
    account_id = "${var.account_id}"
    elb_cert_name = "${var.concourse_staging_elb_cert_name}"
    elb_subnets = "${module.vpc.public_subnet_az2}"
    elb_security_groups = "${module.vpc.web_traffic_security_group}"
}
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
    rds_security_groups = "${module.rds_network.rds_postgres_sg_id},${module.rds_network.rds_mysql_sg_id}"
}

module "concourse_production" {
  source = "../../modules/concourse"
    vpc_id = "${module.vpc.vpc_id}"
    concourse_cidr = "${var.concourse_prod_cidr}"
    route_table_id = "${module.vpc.private_route_table_az1}"
    rds_password = "${var.concourse_prod_rds_password}"
    rds_subnet_group = "${module.rds_network.rds_subnet_group}"
    rds_security_groups = "${module.rds_network.rds_postgres_sg_id},${module.rds_network.rds_mysql_sg_id}"
}

module "concourse_staging" {
  source = "../../modules/concourse"
    vpc_id = "${module.vpc.vpc_id}"
    concourse_cidr = "${var.concourse_staging_cidr}"
    route_table_id = "${module.vpc.private_route_table_az2}"
    rds_password = "${var.concourse_staging_rds_password}"
    rds_subnet_group = "${module.rds_network.rds_subnet_group}"
    rds_security_groups = "${module.rds_network.rds_postgres_sg_id},${module.rds_network.rds_mysql_sg_id}"
}

output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}

output "private_route_table_az1" {
  value = "${module.vpc.private_route_table_az1}"
}

output "private_route_table_az2" {
  value = "${module.vpc.private_route_table_az2}"
}

output "bosh_security_group" {
  value = "${module.vpc.bosh_security_group}"
}
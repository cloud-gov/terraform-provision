/*
 * Tooling stack
 *
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
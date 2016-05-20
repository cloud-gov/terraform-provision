/*
 * Tooling stack
 *
 */

module "vpc" {
    source = "../../modules/bosh_vpc"
}

module "rds" {
    source = "../../modules/rds"

    vpc_id = "${module.vpc.vpc_id}"
    rds_subnet_az1 = "${module.vpc.rds_subnet_az1}"
    rds_subnet_az2 = "${module.vpc.rds_subnet_az2}"

    rds_password = "${var.rds_password}"
}
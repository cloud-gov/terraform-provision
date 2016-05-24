
module "vpc" {
    source = "../../modules/bosh_vpc"

    stack_description = "${var.stack_description}"
    vpc_cidr = "${var.vpc_cidr}"
    private_cidr_1 = "${var.private_cidr_1}"
    private_cidr_2 = "${var.private_cidr_2}"
    public_cidr_1 = "${var.public_cidr_1}"
    public_cidr_2 = "${var.public_cidr_2}"
}

module "rds_network" {
    source = "../../modules/rds_network"

    stack_description = "${var.stack_description}"
    vpc_id = "${module.vpc.vpc_id}"
    rds_private_cidr_1 = "${var.rds_private_cidr_1}"
    rds_private_cidr_2 = "${var.rds_private_cidr_2}"
}

module "rds" {
    source = "../../modules/rds"

    stack_description = "${var.stack_description}"
    rds_password = "${var.rds_password}"
    rds_subnet_group = "${module.rds_network.rds_subnet_group}"
    rds_security_groups = "${module.rds_network.rds_postgres_sg_id},${module.rds_network.rds_mysql_sg_id}"
}

module "vpc_peering" {
    source = "../../modules/vpc_peering"

    peer_owner_id = "${var.peer_owner_id}"
    target_vpc_id = "${var.target_vpc_id}"
    target_vpc_cidr = "${var.target_vpc_cidr}"
    target_az1_route_table = "${var.target_az1_private_route_table}"
    target_az2_route_table = "${var.target_az2_private_route_table}"
    source_vpc_id = "${module.vpc.vpc_id}"
    source_vpc_cidr = "${module.vpc.vpc_cidr}"
    source_az1_route_table = "${module.vpc.private_route_table_az1}"
    source_az2_route_table = "${module.vpc.private_route_table_az2}"
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

module "vpc" {
    source = "../../bosh_vpc"

    stack_description = "${var.stack_description}"
    vpc_cidr = "${var.vpc_cidr}"
    az1 = "${var.az1}"
    az2 = "${var.az2}"
    aws_default_region = "${var.aws_default_region}"
    private_cidr_1 = "${var.private_cidr_1}"
    private_cidr_2 = "${var.private_cidr_2}"
    public_cidr_1 = "${var.public_cidr_1}"
    public_cidr_2 = "${var.public_cidr_2}"
    restricted_ingress_web_cidrs = "${var.restricted_ingress_web_cidrs}"
    restricted_ingress_web_ipv6_cidrs = "${var.restricted_ingress_web_ipv6_cidrs}"
    nat_gateway_instance_type = "${var.nat_gateway_instance_type}"
    monitoring_security_groups = "${var.target_monitoring_security_groups}"
    concourse_security_groups = "${var.target_concourse_security_groups}"
}

module "rds_network" {
    source = "../../rds_network"

    stack_description = "${var.stack_description}"
    az1 = "${var.az1}"
    az2 = "${var.az2}"
    vpc_id = "${module.vpc.vpc_id}"
    security_groups = "${var.rds_security_groups}"
    security_groups_count = "${var.rds_security_groups_count}"
    rds_private_cidr_1 = "${var.rds_private_cidr_1}"
    rds_private_cidr_2 = "${var.rds_private_cidr_2}"
    az1_route_table = "${module.vpc.private_route_table_az1}"
    az2_route_table = "${module.vpc.private_route_table_az2}"
}

module "rds" {
  source = "../../rds"

  stack_description = "${var.stack_description}"
  rds_instance_type = "${var.rds_instance_type}"
  rds_db_size = "${var.rds_db_size}"
  rds_db_engine = "${var.rds_db_engine}"
  rds_db_engine_version = "${var.rds_db_engine_version}"
  rds_db_name = "${var.rds_db_name}"
  rds_username = "${var.rds_username}"
  rds_password = "${var.rds_password}"
  rds_multi_az = "${var.rds_multi_az}"
  rds_subnet_group = "${module.rds_network.rds_subnet_group}"
  rds_security_groups = ["${module.rds_network.rds_postgres_security_group}"]
}

module "credhub_rds" {
  source = "../rds"

  stack_description = "${var.stack_description}"
  rds_db_name = "${var.credhub_rds_db_name}"
  rds_instance_type = "${var.credhub_rds_instance_type}"
  rds_db_size = "${var.credhub_rds_db_size}"
  rds_db_storage_type = "${var.credhub_rds_db_storage_type}"
  rds_db_engine_version = "${var.credhub_rds_engine_version}"
  rds_username = "${var.credhub_rds_username}"
  rds_password = "${var.credhub_rds_password}"
  rds_subnet_group = "${var.rds_subnet_group}"
  rds_security_groups = ["${var.rds_security_groups}"]
  rds_parameter_group_name = "${var.rds_parameter_group_name}"
  rds_force_ssl = "${var.credhub_rds_force_ssl}"
}

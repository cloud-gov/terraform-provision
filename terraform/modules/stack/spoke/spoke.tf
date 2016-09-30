data "terraform_remote_state" "target_vpc" {
    backend = "s3"
    config {
        bucket = "${var.remote_state_bucket}"
        key = "${var.target_stack_name}/terraform.tfstate"
    }
}

module "base" {
    source = "../base"
    stack_description = "${var.stack_description}"
    vpc_cidr = "${var.vpc_cidr}"
    az1 = "${var.az1}"
    az2 = "${var.az2}"
    aws_default_region = "${var.aws_default_region}"
    public_cidr_1 = "${var.public_cidr_1}"
    public_cidr_2 = "${var.public_cidr_2}"
    private_cidr_1 = "${var.private_cidr_1}"
    private_cidr_2 = "${var.private_cidr_2}"
    nat_gateway_instance_type = "${var.nat_gateway_instance_type}"
    nat_gateway_ami = "${var.nat_gateway_ami}"
    rds_private_cidr_1 = "${var.rds_private_cidr_1}"
    rds_private_cidr_2 = "${var.rds_private_cidr_2}"
    rds_instance_type = "${var.rds_instance_type}"
    rds_db_size = "${var.rds_db_size}"
    rds_db_name = "${var.rds_db_name}"
    rds_db_engine = "${var.rds_db_engine}"
    rds_db_engine_version = "${var.rds_db_engine_version}"
    rds_username = "${var.rds_username}"
    rds_password = "${var.rds_password}"
    rds_encrypted = "${var.rds_encrypted}"
    restricted_ingress_web_cidrs = "${var.restricted_ingress_web_cidrs}"
}

module "vpc_peering" {
    source = "../../vpc_peering"

    peer_owner_id = "${var.account_id}"
    target_vpc_id = "${data.terraform_remote_state.target_vpc.vpc_id}"
    target_vpc_cidr = "${data.terraform_remote_state.target_vpc.vpc_cidr}"
    target_az1_route_table = "${data.terraform_remote_state.target_vpc.private_route_table_az1}"
    target_az2_route_table = "${data.terraform_remote_state.target_vpc.private_route_table_az2}"
    source_vpc_id = "${module.base.vpc_id}"
    source_vpc_cidr = "${module.base.vpc_cidr}"
    source_az1_route_table = "${module.base.private_route_table_az1}"
    source_az2_route_table = "${module.base.private_route_table_az2}"
}

module "vpc_security_source_to_target" {
    source = "../../vpc_peering_sg"

    target_bosh_security_group = "${data.terraform_remote_state.target_vpc.bosh_security_group}"
    source_vpc_cidr = "${module.base.vpc_cidr}"
}

module "vpc_security_target_to_source" {
    source = "../../vpc_peering_sg"

    target_bosh_security_group = "${module.base.bosh_security_group}"
    source_vpc_cidr = "${data.terraform_remote_state.target_vpc.vpc_cidr}"
}

module "bosh_user" {
    source = "../../iam_user/bosh_user"
    username = "bosh-${var.stack_description}"
    aws_partition = "${var.aws_partition}"
    account_id = "${var.account_id}"
}

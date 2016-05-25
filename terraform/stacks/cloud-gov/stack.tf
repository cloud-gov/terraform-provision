
module "tooling_stack" {
    source = "../tooling"

    account_id = "${var.account_id}"
    rds_password = "${var.tooling_rds_password}"
    concourse_prod_rds_password = "${var.concourse_prod_rds_password}"
    concourse_staging_rds_password = "${var.concourse_staging_rds_password}"
}

module "production_stack" {
    source = "../production"

    rds_password = "${var.prod_rds_password}"
    peer_owner_id = "${var.account_id}"
    target_vpc_id = "${module.tooling_stack.vpc_id}"
    target_az1_private_route_table = "${module.tooling_stack.private_route_table_az1}"
    target_az2_private_route_table = "${module.tooling_stack.private_route_table_az2}"
    target_bosh_security_group = "${module.tooling_stack.bosh_security_group}"
}

module "staging_stack" {
    source = "../staging"

    rds_password = "${var.staging_rds_password}"
    peer_owner_id = "${var.account_id}"
    target_vpc_id = "${module.tooling_stack.vpc_id}"
    target_az1_private_route_table = "${module.tooling_stack.private_route_table_az1}"
    target_az2_private_route_table = "${module.tooling_stack.private_route_table_az2}"
    target_bosh_security_group = "${module.tooling_stack.bosh_security_group}"
}
module "stack" {
    source = "../../modules/stack/spoke"

    stack_description = "${var.stack_description}"
    vpc_cidr = "${var.vpc_cidr}"
    public_cidr_1 = "${var.public_cidr_1}"
    public_cidr_2 = "${var.public_cidr_2}"
    private_cidr_1 = "${var.private_cidr_1}"
    private_cidr_2 = "${var.private_cidr_2}"
    rds_private_cidr_1 = "${var.rds_private_cidr_1}"
    rds_private_cidr_2 = "${var.rds_private_cidr_2}"
    restricted_ingress_web_cidrs = "${var.restricted_ingress_web_cidrs}"
    rds_password = "${var.rds_password}"
    rds_encrypted = true
    account_id = "${var.account_id}"
    remote_state_bucket = "${var.remote_state_bucket}"
    target_stack_name = "${var.target_stack_name}"
    nat_gateway_ami = "${var.nat_gateway_ami}"
    az1 = "${var.az1}"
    az2 = "${var.az2}"

}

module "cf" {
    source = "../../modules/cloudfoundry"

    account_id = "${var.account_id}"
    stack_description = "${var.stack_description}"
    aws_partition = "${var.aws_partition}"
    elb_main_cert_name = "${var.main_cert_name}"
    elb_apps_cert_name = "${var.apps_cert_name}"
    elb_subnets = "${module.stack.public_subnet_az1},${module.stack.public_subnet_az2}"
    elb_security_groups = "${module.stack.web_traffic_security_group}"

    rds_password = "${var.cf_rds_password}"
    rds_subnet_group = "${module.stack.rds_subnet_group}"
    rds_security_groups = "${module.stack.rds_postgres_security_group}"
    stack_prefix = "cf-staging"

    vpc_id = "${module.stack.vpc_id}"
    private_route_table_az1 = "${module.stack.private_route_table_az1}"
    private_route_table_az2 = "${module.stack.private_route_table_az2}"
    stack_description = "${var.stack_description}"
    services_cidr_1 = "${var.services_cidr_1}"
    services_cidr_2 = "${var.services_cidr_2}"

    monitoring_elb_cert_name = "${var.monitoring_elb_cert_name}"
    az1 = "${var.az1}"
    az2 = "${var.az2}"
}

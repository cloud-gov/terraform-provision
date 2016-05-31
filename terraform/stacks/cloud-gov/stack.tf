
module "tooling_stack" {
    source = "../tooling"

    account_id = "${var.account_id}"
    rds_password = "${var.tooling_rds_password}"
    concourse_prod_rds_password = "${var.concourse_prod_rds_password}"
    concourse_staging_rds_password = "${var.concourse_staging_rds_password}"

    concourse_prod_cidr = "10.99.30.0/24"
    concourse_staging_cidr = "10.99.31.0/24"
    vpc_cidr = "10.99.0.0/16"
    az1 = "${var.az1}"
    az2 = "${var.az2}"
    public_cidr_1 = "10.99.100.0/24"
    public_cidr_2 = "10.99.101.0/24"
    private_cidr_1 = "10.99.1.0/24"
    private_cidr_2 = "10.99.2.0/24"
    rds_private_cidr_1 = "10.99.20.0/24"
    rds_private_cidr_2 = "10.99.21.0/24"
}

module "production_stack" {
    source = "../production"

    rds_password = "${var.prod_rds_password}"
    account_id = "${var.account_id}"
    vpc_cidr = "10.10.0.0/16"
    public_cidr_1 = "10.10.100.0/24"
    public_cidr_2 = "10.10.101.0/24"
    private_cidr_1 = "10.10.1.0/24"
    private_cidr_2 = "10.10.2.0/24"
    rds_private_cidr_1 = "10.10.20.0/24"
    rds_private_cidr_2 = "10.10.21.0/24"
    remote_state_bucket = "terraform-state"
}

module "staging_stack" {
    source = "../staging"

    rds_password = "${var.staging_rds_password}"
    account_id = "${var.account_id}"
    vpc_cidr = "10.9.0.0/16"
    public_cidr_1 = "10.9.100.0/24"
    public_cidr_2 = "10.9.101.0/24"
    private_cidr_1 = "10.9.1.0/24"
    private_cidr_2 = "10.9.2.0/24"
    rds_private_cidr_1 = "10.9.20.0/24"
    rds_private_cidr_2 = "10.9.21.0/24"
    remote_state_bucket = "terraform-state"
}
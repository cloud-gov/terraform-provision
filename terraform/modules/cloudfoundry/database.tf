module "cf_database" {
    source = "../rds"

    stack_description = "${var.stack_description}"
    rds_instance_type = "${var.rds_instance_type}"
    rds_db_size = "${var.rds_db_size}"
    rds_db_engine = "${var.rds_db_engine}"
    rds_db_engine_version = "${var.rds_db_engine_version}"
    rds_username = "${var.rds_username}"
    rds_password = "${var.rds_password}"
    rds_subnet_group = "${var.rds_subnet_group}"
    rds_security_groups = "${var.rds_security_groups}"
}

provider "postgresql" {
    alias = "cf_rds"
    host = "${module.cf_database.rds_host}"
    username = "${var.rds_username}"
    password = "${var.rds_password}"
    ssl_mode = "require"
}

resource "postgresql_database" "uaadb" {
    provider = "postgresql.cf_rds"
    name = "uaadb"
}
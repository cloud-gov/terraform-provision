terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.8.0"
}

data "aws_caller_identity" "current" {}

locals {
  aws_partition = "${element(split(":", data.aws_caller_identity.current.arn), 1)}"
}

module "stack" {
  source = "../../modules/stack/base"

  stack_description = "${var.stack_description}"
  vpc_cidr = "${var.vpc_cidr}"
  az1 = "${var.az1}"
  az2 = "${var.az2}"
  aws_default_region = "${var.aws_default_region}"
  public_cidr_1 = "${var.public_cidr_1}"
  public_cidr_2 = "${var.public_cidr_2}"
  private_cidr_1 = "${var.private_cidr_1}"
  private_cidr_2 = "${var.private_cidr_2}"
  restricted_ingress_web_cidrs = "${var.restricted_ingress_web_cidrs}"
  rds_private_cidr_1 = "${var.rds_private_cidr_1}"
  rds_private_cidr_2 = "${var.rds_private_cidr_2}"
  rds_password = "${var.rds_password}"
  rds_security_groups = ["${module.stack.bosh_security_group}"]
  rds_security_groups_count = "1"
}

module "concourse_production" {
  source = "../../modules/concourse"
  stack_description = "${var.stack_description}"
  aws_partition = "${local.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  concourse_cidr = "${var.concourse_prod_cidr}"
  concourse_az = "${var.az1}"
  route_table_id = "${module.stack.private_route_table_az1}"
  rds_password = "${var.concourse_prod_rds_password}"
  rds_subnet_group = "${module.stack.rds_subnet_group}"
  rds_security_groups = ["${module.stack.rds_postgres_security_group}"]
  rds_parameter_group_name = "tooling-concourse-production"
  rds_instance_type = "db.m3.xlarge"
  account_id = "${data.aws_caller_identity.current.account_id}"
  rds_multi_az = "${var.rds_multi_az}"
  rds_final_snapshot_identifier = "final-snapshot-atc-tooling-production"
  elb_cert_name = "${var.concourse_prod_elb_cert_name}"
  elb_subnets = ["${module.stack.public_subnet_az1}"]
  elb_security_groups = ["${module.stack.restricted_web_traffic_security_group}"]
}

module "concourse_staging" {
  source = "../../modules/concourse"
  stack_description = "${var.stack_description}"
  aws_partition = "${local.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  concourse_cidr = "${var.concourse_staging_cidr}"
  concourse_az = "${var.az2}"
  route_table_id = "${module.stack.private_route_table_az2}"
  rds_password = "${var.concourse_staging_rds_password}"
  rds_subnet_group = "${module.stack.rds_subnet_group}"
  rds_security_groups = ["${module.stack.rds_postgres_security_group}"]
  rds_parameter_group_name = "tooling-concourse-staging"
  rds_instance_type = "db.m3.medium"
  account_id = "${data.aws_caller_identity.current.account_id}"
  rds_multi_az = "${var.rds_multi_az}"
  rds_final_snapshot_identifier = "final-snapshot-atc-tooling-staging"
  elb_cert_name = "${var.concourse_staging_elb_cert_name}"
  elb_subnets = ["${module.stack.public_subnet_az2}"]
  elb_security_groups = ["${module.stack.restricted_web_traffic_security_group}"]
}

module "monitoring_production" {
  source = "../../modules/monitoring"
  stack_description = "production"
  aws_partition = "${local.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  monitoring_cidr = "${var.monitoring_production_cidr}"
  monitoring_az = "${var.az1}"
  route_table_id = "${module.stack.private_route_table_az1}"
  account_id = "${data.aws_caller_identity.current.account_id}"
  elb_cert_name = "${var.monitoring_production_elb_cert_name}"
  elb_subnets = ["${module.stack.public_subnet_az1}"]
  elb_security_groups = ["${module.stack.web_traffic_security_group}"]
  prometheus_elb_security_groups = "${module.stack.restricted_web_traffic_security_group}"
}

module "monitoring_staging" {
  source = "../../modules/monitoring"
  stack_description = "staging"
  aws_partition = "${local.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  monitoring_cidr = "${var.monitoring_staging_cidr}"
  monitoring_az = "${var.az2}"
  route_table_id = "${module.stack.private_route_table_az2}"
  account_id = "${data.aws_caller_identity.current.account_id}"
  elb_cert_name = "${var.monitoring_staging_elb_cert_name}"
  elb_subnets = ["${module.stack.public_subnet_az2}"]
  elb_security_groups = ["${module.stack.web_traffic_security_group}"]
  prometheus_elb_security_groups = "${module.stack.restricted_web_traffic_security_group}"
}

resource "aws_eip" "production_dns_eip" {
  vpc = true

  count = "${var.dns_eip_count_production}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "staging_dns_eip" {
  vpc = true

  count = "${var.dns_eip_count_staging}"

  lifecycle {
    prevent_destroy = true
  }
}

module "dns" {
  source = "../../modules/dns"
  stack_description = "${var.stack_description}"
  vpc_id = "${module.stack.vpc_id}"
}

terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.12.0"
}

data "aws_caller_identity" "current" {}

data "aws_iam_server_certificate" "wildcard_production" {
  name_prefix = "${var.wildcard_production_prefix}"
  latest = true
}

data "aws_iam_server_certificate" "wildcard_staging" {
  name_prefix = "${var.wildcard_staging_prefix}"
  latest = true
}

locals {
  aws_partition = "${element(split(":", data.aws_caller_identity.current.arn), 1)}"
}

resource "aws_lb" "main" {
  name = "${var.stack_description}-main"
  subnets = ["${module.stack.public_subnet_az1}", "${module.stack.public_subnet_az2}"]
  security_groups = ["${module.stack.restricted_web_traffic_security_group}"]
  ip_address_type = "dualstack"
  idle_timeout = 3600
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = "${var.production_cert_name != "" ?
    "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.production_cert_name}" :
    data.aws_iam_server_certificate.wildcard_production.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.dummy.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "dummy" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.stack.vpc_id}"
}

resource "aws_lb_listener_certificate" "main-staging" {
  count = "${var.use_staging_certificate ? 1 : 0}"

  listener_arn    = "${aws_lb_listener.main.arn}"
  certificate_arn = "${var.staging_cert_name != "" ?
    "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.staging_cert_name}" :
    data.aws_iam_server_certificate.wildcard_staging.arn}"
}

module "stack" {
  source = "../../modules/stack/base"

  stack_description = "${var.stack_description}"
  vpc_cidr = "${var.vpc_cidr}"
  az1 = "${var.az1}"
  az2 = "${var.az2}"
  aws_default_region = "${var.aws_default_region}"
  public_cidr_1 = "${cidrsubnet(var.vpc_cidr, 8, 100)}"
  public_cidr_2 = "${cidrsubnet(var.vpc_cidr, 8, 101)}"
  private_cidr_1 = "${cidrsubnet(var.vpc_cidr, 8, 1)}"
  private_cidr_2 = "${cidrsubnet(var.vpc_cidr, 8, 2)}"
  restricted_ingress_web_cidrs = "${var.restricted_ingress_web_cidrs}"
  restricted_ingress_web_ipv6_cidrs = "${var.restricted_ingress_web_ipv6_cidrs}"
  rds_private_cidr_1 = "${var.rds_private_cidr_1}"
  rds_private_cidr_2 = "${var.rds_private_cidr_2}"
  rds_password = "${var.rds_password}"
  rds_multi_az = "${var.rds_multi_az}"
  rds_security_groups = ["${module.stack.bosh_security_group}"]
  rds_security_groups_count = "1"
  use_nat_gateway_eip = "${var.use_nat_gateway_eip}"
}

module "concourse_production" {
  source = "../../modules/concourse"
  stack_description = "${var.stack_description}"
  vpc_id = "${module.stack.vpc_id}"
  concourse_cidr = "${cidrsubnet(var.vpc_cidr, 8, 30)}"
  concourse_az = "${var.az1}"
  route_table_id = "${module.stack.private_route_table_az1}"
  rds_password = "${var.concourse_prod_rds_password}"
  rds_subnet_group = "${module.stack.rds_subnet_group}"
  rds_security_groups = ["${module.stack.rds_postgres_security_group}"]
  rds_parameter_group_name = "tooling-concourse-production"
  rds_instance_type = "db.m3.xlarge"
  rds_multi_az = "${var.rds_multi_az}"
  rds_final_snapshot_identifier = "final-snapshot-atc-tooling-production"
  listener_arn = "${aws_lb_listener.main.arn}"
  hosts = ["${var.concourse_production_hosts}"]
}

module "concourse_staging" {
  source = "../../modules/concourse"
  stack_description = "${var.stack_description}"
  vpc_id = "${module.stack.vpc_id}"
  concourse_cidr = "${cidrsubnet(var.vpc_cidr, 8, 31)}"
  concourse_az = "${var.az2}"
  route_table_id = "${module.stack.private_route_table_az2}"
  rds_password = "${var.concourse_staging_rds_password}"
  rds_subnet_group = "${module.stack.rds_subnet_group}"
  rds_security_groups = ["${module.stack.rds_postgres_security_group}"]
  rds_parameter_group_name = "tooling-concourse-staging"
  rds_instance_type = "db.m3.medium"
  rds_multi_az = "${var.rds_multi_az}"
  rds_final_snapshot_identifier = "final-snapshot-atc-tooling-staging"
  listener_arn = "${aws_lb_listener.main.arn}"
  hosts = ["${var.concourse_staging_hosts}"]
}

module "monitoring_production" {
  source = "../../modules/monitoring"
  stack_description = "production"
  vpc_id = "${module.stack.vpc_id}"
  monitoring_cidr = "${cidrsubnet(var.vpc_cidr, 8, 32)}"
  monitoring_az = "${var.az1}"
  route_table_id = "${module.stack.private_route_table_az1}"
  listener_arn = "${aws_lb_listener.main.arn}"
  hosts = ["${var.monitoring_production_hosts}"]
}

module "monitoring_staging" {
  source = "../../modules/monitoring"
  stack_description = "staging"
  vpc_id = "${module.stack.vpc_id}"
  monitoring_cidr = "${cidrsubnet(var.vpc_cidr, 8, 33)}"
  monitoring_az = "${var.az2}"
  route_table_id = "${module.stack.private_route_table_az2}"
  listener_arn = "${aws_lb_listener.main.arn}"
  hosts = ["${var.monitoring_staging_hosts}"]
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

module "smtp" {
  source = "../../modules/smtp"
  stack_description = "${var.stack_description}"
  vpc_id = "${module.stack.vpc_id}"
  ingress_cidr_blocks = ["${var.smtp_ingress_cidr_blocks}"]
}

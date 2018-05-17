terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.12.0"
}

data "terraform_remote_state" "target_vpc" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "${var.target_stack_name}/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_server_certificate" "wildcard" {
  name_prefix = "${var.wildcard_prefix}"
  latest = true
}

locals {
  aws_partition = "${element(split(":", data.aws_caller_identity.current.arn), 1)}"
}

resource "aws_lb" "main" {
  name = "${var.stack_description}-main"
  subnets = ["${module.stack.public_subnet_az1}", "${module.stack.public_subnet_az2}"]
  security_groups = ["${var.force_restricted_network == "no" ?
    module.stack.web_traffic_security_group :
    module.stack.restricted_web_traffic_security_group}"]
  ip_address_type = "dualstack"
  idle_timeout = 3600
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = "${var.main_cert_name != "" ?
    "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.main_cert_name}" :
    data.aws_iam_server_certificate.wildcard.arn}"

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

module "stack" {
    source = "../../modules/stack/spoke"

    stack_description = "${var.stack_description}"
    aws_partition = "${local.aws_partition}"
    vpc_cidr = "${var.vpc_cidr}"
    aws_default_region = "${var.aws_default_region}"
    public_cidr_1 = "${cidrsubnet(var.vpc_cidr, 8, 100)}"
    public_cidr_2 = "${cidrsubnet(var.vpc_cidr, 8, 101)}"
    private_cidr_1 = "${cidrsubnet(var.vpc_cidr, 8, 1)}"
    private_cidr_2 = "${cidrsubnet(var.vpc_cidr, 8, 2)}"
    rds_private_cidr_1 = "${var.rds_private_cidr_1}"
    rds_private_cidr_2 = "${var.rds_private_cidr_2}"
    restricted_ingress_web_cidrs = "${var.restricted_ingress_web_cidrs}"
    restricted_ingress_web_ipv6_cidrs = "${var.restricted_ingress_web_ipv6_cidrs}"
    rds_password = "${var.rds_password}"
    account_id = "${data.aws_caller_identity.current.account_id}"

    target_vpc_id = "${data.terraform_remote_state.target_vpc.vpc_id}"
    target_vpc_cidr = "${data.terraform_remote_state.target_vpc.vpc_cidr}"
    target_bosh_security_group = "${data.terraform_remote_state.target_vpc.bosh_security_group}"
    target_az1_route_table = "${data.terraform_remote_state.target_vpc.private_route_table_az1}"
    target_az2_route_table = "${data.terraform_remote_state.target_vpc.private_route_table_az2}"
    target_monitoring_security_groups = [
      "${lookup(data.terraform_remote_state.target_vpc.monitoring_security_groups, var.stack_description)}"
    ]
    target_concourse_security_groups = [
      "${data.terraform_remote_state.target_vpc.production_concourse_security_group}",
      "${data.terraform_remote_state.target_vpc.staging_concourse_security_group}"
    ]
    use_nat_gateway_eip = "${var.use_nat_gateway_eip}"
}

module "cf" {
    source = "../../modules/cloudfoundry"

    stack_description = "${var.stack_description}"
    aws_partition = "${local.aws_partition}"
    elb_main_cert_id = "${var.main_cert_name != "" ?
      "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.main_cert_name}" :
      data.aws_iam_server_certificate.wildcard.arn}"
    elb_apps_cert_id = "${var.apps_cert_name != "" ?
      "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.apps_cert_name}" :
      data.aws_iam_server_certificate.wildcard.arn}"
    elb_subnets = ["${module.stack.public_subnet_az1}", "${module.stack.public_subnet_az2}"]
    elb_security_groups = ["${var.force_restricted_network == "no" ?
      module.stack.web_traffic_security_group :
      module.stack.restricted_web_traffic_security_group}"]

    rds_password = "${var.cf_rds_password}"
    rds_subnet_group = "${module.stack.rds_subnet_group}"
    rds_security_groups = ["${module.stack.rds_postgres_security_group}"]
    stack_prefix = "${var.stack_prefix}"

    vpc_id = "${module.stack.vpc_id}"
    private_route_table_az1 = "${module.stack.private_route_table_az1}"
    private_route_table_az2 = "${module.stack.private_route_table_az2}"
    
    services_cidr_1 = "${cidrsubnet(var.vpc_cidr, 8, 30)}" 
    services_cidr_2 = "${cidrsubnet(var.vpc_cidr, 8, 31)}"
    kubernetes_cluster_id = "${var.kubernetes_cluster_id}"
    bucket_prefix = "${var.bucket_prefix}"
    additional_certificates = ["${compact(
      list(
        "${var.18f_gov_elb_cert_name != "" ?
          "arn:${local.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/${var.18f_gov_elb_cert_name}" :
          ""}"
      )
    )}"]
}

module "diego" {
    source = "../../modules/diego"

    stack_description = "${var.stack_description}"
    elb_subnets = ["${module.stack.public_subnet_az1}","${module.stack.public_subnet_az2}"]

    vpc_id = "${module.stack.vpc_id}"
    stack_description = "${var.stack_description}"
    # Workaround for https://github.com/hashicorp/terraform/issues/12453
    ingress_cidrs = "${split(",",
      var.force_restricted_network == "no" ?
        "0.0.0.0/0" : join(",", var.restricted_ingress_web_cidrs))}"
}

module "kubernetes" {
    source = "../../modules/kubernetes"

    stack_description = "${var.stack_description}"
    aws_default_region = "${var.aws_default_region}"

    vpc_id = "${module.stack.vpc_id}"
    vpc_cidr = "${var.vpc_cidr}"
    tooling_vpc_cidr = "${data.terraform_remote_state.target_vpc.vpc_cidr}"
    elb_subnets = ["${module.cf.services_subnet_az1}","${module.cf.services_subnet_az2}"]
    target_bosh_security_group = "${module.stack.bosh_security_group}"
    target_monitoring_security_group = "${lookup(data.terraform_remote_state.target_vpc.monitoring_security_groups, var.stack_description)}"
    target_concourse_security_group = "${data.terraform_remote_state.target_vpc.production_concourse_security_group}"
}

module "logsearch" {
    source = "../../modules/logsearch"

    stack_description = "${var.stack_description}"
    vpc_id = "${module.stack.vpc_id}"
    private_elb_subnets = ["${module.cf.services_subnet_az1}","${module.cf.services_subnet_az2}"]
    bosh_security_group = "${module.stack.bosh_security_group}"
    listener_arn = "${aws_lb_listener.main.arn}"
    hosts = ["${var.platform_kibana_hosts}"]
}

module "shibboleth" {
    source = "../../modules/shibboleth"

    stack_description = "${var.stack_description}"
    vpc_id = "${module.stack.vpc_id}"
    listener_arn = "${aws_lb_listener.main.arn}"
    hosts = ["${var.shibboleth_hosts}"]
}

module "elasticache_broker_network" {
  source = "../../modules/elasticache_broker_network"
  stack_description = "${var.stack_description}"
  elasticache_private_cidr_1 = "${cidrsubnet(var.vpc_cidr, 8, 34)}"
  elasticache_private_cidr_2 = "${cidrsubnet(var.vpc_cidr, 8, 35)}"
  az1_route_table = "${module.stack.private_route_table_az1}"
  az2_route_table = "${module.stack.private_route_table_az2}"
  vpc_id = "${module.stack.vpc_id}"
  security_groups = ["${module.stack.bosh_security_group}"]
  elb_subnets = ["${module.cf.services_subnet_az1}","${module.cf.services_subnet_az2}"]
  elb_security_groups = ["${module.stack.bosh_security_group}"]
}

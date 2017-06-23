/*
 * Tooling stack
 *
 * This stack relies on defaults heavily. Please look through
 * all the module sources, and specifically, the variables.tf
 * in each module, which declares these defaults.
 */

terraform {
  backend "s3" {}
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
}

module "concourse_production" {
  source = "../../modules/concourse"
  stack_description = "${var.stack_description}"
  aws_partition = "${var.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  concourse_cidr = "${var.concourse_prod_cidr}"
  concourse_az = "${var.az1}"
  route_table_id = "${module.stack.private_route_table_az1}"
  rds_password = "${var.concourse_prod_rds_password}"
  rds_subnet_group = "${module.stack.rds_subnet_group}"
  rds_security_groups = "${module.stack.rds_postgres_security_group}"
  rds_parameter_group_name = "tooling-concourse-production"
  rds_instance_type = "db.m3.xlarge"
  account_id = "${var.account_id}"
  elb_cert_name = "${var.concourse_prod_elb_cert_name}"
  elb_subnets = "${module.stack.public_subnet_az1}"
  elb_security_groups = "${module.stack.restricted_web_traffic_security_group}"
}

module "concourse_staging" {
  source = "../../modules/concourse"
  stack_description = "${var.stack_description}"
  aws_partition = "${var.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  concourse_cidr = "${var.concourse_staging_cidr}"
  concourse_az = "${var.az2}"
  route_table_id = "${module.stack.private_route_table_az2}"
  rds_password = "${var.concourse_staging_rds_password}"
  rds_subnet_group = "${module.stack.rds_subnet_group}"
  rds_security_groups = "${module.stack.rds_postgres_security_group}"
  rds_parameter_group_name = "tooling-concourse-staging"
  rds_instance_type = "db.m3.medium"
  account_id = "${var.account_id}"
  elb_cert_name = "${var.concourse_staging_elb_cert_name}"
  elb_subnets = "${module.stack.public_subnet_az2}"
  elb_security_groups = "${module.stack.restricted_web_traffic_security_group}"
}

module "monitoring_production" {
  source = "../../modules/monitoring"
  stack_description = "production"
  aws_partition = "${var.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  monitoring_cidr = "${var.monitoring_production_cidr}"
  monitoring_az = "${var.az1}"
  route_table_id = "${module.stack.private_route_table_az1}"
  account_id = "${var.account_id}"
  elb_cert_name = "${var.monitoring_production_elb_cert_name}"
  elb_subnets = "${module.stack.public_subnet_az1}"
  elb_security_groups = "${module.stack.web_traffic_security_group}"
  prometheus_elb_security_groups = "${module.stack.restricted_web_traffic_security_group}"
}

module "monitoring_staging" {
  source = "../../modules/monitoring"
  stack_description = "staging"
  aws_partition = "${var.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  monitoring_cidr = "${var.monitoring_staging_cidr}"
  monitoring_az = "${var.az2}"
  route_table_id = "${module.stack.private_route_table_az2}"
  account_id = "${var.account_id}"
  elb_cert_name = "${var.monitoring_staging_elb_cert_name}"
  elb_subnets = "${module.stack.public_subnet_az2}"
  elb_security_groups = "${module.stack.web_traffic_security_group}"
  prometheus_elb_security_groups = "${module.stack.restricted_web_traffic_security_group}"
}

module "billing_bucket_staging" {
  source = "../../modules/s3_bucket/encrypted_bucket"
  bucket = "cg-billing-staging"
  aws_partition = "${var.aws_partition}"
}

module "billing_bucket_production" {
  source = "../../modules/s3_bucket/encrypted_bucket"
  bucket = "cg-billing-production"
  aws_partition = "${var.aws_partition}"
}

module "cg_binaries_bucket" {
  source = "../../modules/s3_bucket/encrypted_bucket"
  bucket = "cg-binaries"
  aws_partition = "${var.aws_partition}"
}

module "billing_user" {
  source = "../../modules/iam_user/billing_user"
  username = "cg-billing"
  billing_bucket = "cg-billing-*"
  aws_partition = "${var.aws_partition}"
}

module "stemcell_user" {
  source = "../../modules/iam_user/stemcell_user"
  username = "stemcell"
  aws_partition = "${var.aws_partition}"
  stemcell_bucket = "cg-stemcell-images"
}

module "blobstore_policy" {
  source = "../../modules/iam_role_policy/blobstore"
  policy_name = "blobstore"
  aws_partition = "${var.aws_partition}"
  bucket_name = "${var.blobstore_bucket_name}"
}

module "cloudwatch_policy" {
  source = "../../modules/iam_role_policy/cloudwatch"
  policy_name = "${var.stack_description}-cloudwatch"
}

module "bosh_policy" {
  source = "../../modules/iam_role_policy/bosh"
  policy_name = "${var.stack_description}-bosh"
  aws_partition = "${var.aws_partition}"
  account_id = "${var.account_id}"
  bucket_name = "${var.blobstore_bucket_name}"
}

module "bosh_compilation_policy" {
  source = "../../modules/iam_role_policy/bosh_compilation"
  policy_name = "${var.stack_description}-bosh-compilation"
  aws_partition = "${var.aws_partition}"
  bucket_name = "${var.blobstore_bucket_name}"
}

module "riemann_monitoring_policy" {
  source = "../../modules/iam_role_policy/riemann_monitoring"
  policy_name = "riemann-monitoring"
  aws_default_region = "${var.aws_default_region}"
  aws_partition = "${var.aws_partition}"
  account_id = "${var.account_id}"
}

module "influxdb_monitoring_policy" {
  source = "../../modules/iam_role_policy/influxdb_archive"
  policy_name = "influxdb-archive"
  aws_partition = "${var.aws_partition}"
}

module "concourse_worker_policy" {
  source = "../../modules/iam_role_policy/concourse_worker"
  policy_name = "concourse-worker"
  aws_partition = "${var.aws_partition}"
  varz_bucket = "cloud-gov-varz"
  varz_staging_bucket = "cloud-gov-varz-stage"
  bosh_release_bucket = "cloud-gov-bosh-releases"
  stemcell_bucket = "cg-stemcell-images"
  terraform_state_bucket = "terraform-state"
  semver_bucket = "cg-semver"
  billing_bucket = "cg-billing-*"
}

module "concourse_iaas_worker_policy" {
  source = "../../modules/iam_role_policy/concourse_iaas_worker"
  policy_name = "concourse-iaas-worker"
}

module "default_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-default"
}

module "master_bosh_role" {
  source = "../../modules/iam_role"
  role_name = "master-bosh"
}

module "bosh_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-bosh"
}

module "bosh_compilation_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-bosh-compilation"
}

module "riemann_monitoring_role" {
  source = "../../modules/iam_role"
  role_name = "riemann-monitoring"
}

module "influxdb_monitoring_role" {
  source = "../../modules/iam_role"
  role_name = "influxdb-monitoring"
}

module "concourse_worker_role" {
  source = "../../modules/iam_role"
  role_name = "tooling-concourse-worker"
}

module "concourse_iaas_worker_role" {
  source = "../../modules/iam_role"
  role_name = "tooling-concourse-iaas-worker"
}

resource "aws_iam_policy_attachment" "blobstore" {
  name = "${var.stack_description}-blobstore"
  policy_arn = "${module.blobstore_policy.arn}"
  roles = [
    "${module.default_role.role_name}",
    "${module.bosh_role.role_name}",
    "${module.riemann_monitoring_role.role_name}",
    "${module.influxdb_monitoring_role.role_name}",
    "${module.concourse_worker_role.role_name}",
    "${module.concourse_iaas_worker_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name = "${var.stack_description}-cloudwatch"
  policy_arn = "${module.cloudwatch_policy.arn}"
  roles = [
    "${module.default_role.role_name}",
    "${module.bosh_role.role_name}",
    "${module.bosh_compilation_role.role_name}",
    "${module.riemann_monitoring_role.role_name}",
    "${module.influxdb_monitoring_role.role_name}",
    "${module.concourse_worker_role.role_name}",
    "${module.concourse_iaas_worker_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "bosh" {
  name = "${var.stack_description}-bosh"
  policy_arn = "${module.bosh_policy.arn}"
  roles = [
    "${module.master_bosh_role.role_name}",
    "${module.bosh_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "bosh_compilation" {
  name = "${var.stack_description}-bosh-compilation"
  policy_arn = "${module.bosh_compilation_policy.arn}"
  roles = [
    "${module.bosh_compilation_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "riemann_monitoring" {
  name = "riemann_monitoring"
  policy_arn = "${module.riemann_monitoring_policy.arn}"
  roles = [
    "${module.riemann_monitoring_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "influxdb_monitoring" {
  name = "influxdb_monitoring"
  policy_arn = "${module.influxdb_monitoring_policy.arn}"
  roles = [
    "${module.influxdb_monitoring_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "concourse_worker" {
  name = "concourse_worker"
  policy_arn = "${module.concourse_worker_policy.arn}"
  roles = [
    "${module.concourse_worker_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "concourse_iaas_worker" {
  name = "concourse_iaas_worker"
  policy_arn = "${module.concourse_iaas_worker_policy.arn}"
  roles = [
    "${module.concourse_iaas_worker_role.role_name}"
  ]
}

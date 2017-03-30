/*
 * Tooling stack
 *
 * This stack relies on defaults heavily. Please look through
 * all the module sources, and specifically, the variables.tf
 * in each module, which declares these defaults.
 */

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
  rds_security_groups = "${module.stack.rds_postgres_security_group},${module.stack.rds_mysql_security_group}"
  rds_parameter_group_name = "concourse-production"
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
  rds_security_groups = "${module.stack.rds_postgres_security_group},${module.stack.rds_mysql_security_group}"
  rds_parameter_group_name = "concourse-staging"
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

module "tooling_bosh_user" {
  source = "../../modules/iam_user/bosh_user"
  username = "bosh-tooling"
  account_id = "${var.account_id}"
  aws_partition = "${var.aws_partition}"
}

module "master_bosh_user" {
  source = "../../modules/iam_user/bosh_user"
  username = "bosh-master"
  account_id = "${var.account_id}"
  aws_partition = "${var.aws_partition}"
}

module "ci_user" {
  source = "../../modules/iam_user/concourse_user"
  username = "concourse"
  aws_partition = "${var.aws_partition}"
}

# This user WILL be removed once east has been shutdown.  DO NOT USE these credentials in the GovCloud environment
module "ci_user_east" {
  source = "../../modules/iam_user/concourse_user_east"
  username = "concourse-east"
  aws_partition = "${var.aws_partition}"
}

module "cf_user" {
  source = "../../modules/iam_user/cf_user"
  username = "cf-cc-s3"
  aws_partition = "${var.aws_partition}"
}

module "release_user" {
  source = "../../modules/iam_user/release_user"
  username = "releaser"
  aws_partition = "${var.aws_partition}"
}

module "stemcell_user" {
  source = "../../modules/iam_user/stemcell_user"
  username = "stemcell"
  aws_partition = "${var.aws_partition}"
  stemcell_bucket = "cg-stemcell-images"
}

module "limit_check_user" {
  source = "../../modules/iam_user/limit_check_user"
  username = "limit-check"
}

module "aws_broker_user" {
  source = "../../modules/iam_user/aws_broker_user"
  username = "aws-broker"
  account_id = "${var.account_id}"
  aws_default_region = "${var.aws_default_region}"
  remote_state_bucket = "${var.remote_state_bucket}"
  aws_partition = "${var.aws_partition}"
}

module "concourse_worker_role" {
  source = "../../modules/iam_role/concourse_worker"
  role_name = "concourse-worker"
  aws_partition = "${var.aws_partition}"
  varz_bucket = "cloud-gov-varz"
  varz_staging_bucket = "cloud-gov-varz-stage"
  bosh_release_bucket = "cloud-gov-bosh-releases"
  stemcell_bucket = "cg-stemcell-images"
  terraform_state_bucket = "terraform-state"
}

module "kubernetes_master_role" {
  source = "../../modules/iam_role/kubernetes_master"
  stack_description = "${var.stack_description}"
  aws_partition = "${var.aws_partition}"
  aws_default_region = "${var.aws_default_region}"
  account_id = "${var.account_id}"
  role_name = "k8s-master"
}

module "kubernetes_minion_role" {
  source = "../../modules/iam_role/kubernetes_minion"
  stack_description = "${var.stack_description}"
  aws_partition = "${var.aws_partition}"
  aws_default_region = "${var.aws_default_region}"
  account_id = "${var.account_id}"
  role_name = "k8s-minion"
}

module "kubernetes_node_role" {
  source = "../../modules/iam_role/kubernetes_node"
  role_name = "k8s-node"
  aws_partition = "${var.aws_partition}"
  account_id = "${var.account_id}"
  master_role = "k8s-master"
  minion_role = "k8s-minion"
  assume_role_path = "/bosh-passed/"
}

module "kubernetes_logger_role" {
  source = "../../modules/iam_role/kubernetes_logger"
  role_name = "k8s-logger"
  aws_default_region = "${var.aws_default_region}"
  aws_partition = "${var.aws_partition}"
  account_id = "${var.account_id}"
  master_role = "k8s-master"
  minion_role = "k8s-minion"
  assume_role_path = "/bosh-passed/"
}

module "cloudwatch_logs_role" {
  source = "../../modules/iam_role/cloudwatch_logs"
  role_name = "cloudwatch-logs"
}

module "riemann_monitoring_role" {
  source = "../../modules/iam_role/riemann_monitoring"
  role_name = "riemann-monitoring"
  aws_default_region = "${var.aws_default_region}"
  aws_partition = "${var.aws_partition}"
  account_id = "${var.account_id}"
}

module "influxdb_archive_role" {
  source = "../../modules/iam_role/influxdb_archive"
  role_name = "influxdb-archive"
  aws_partition = "${var.aws_partition}"
}

resource "aws_iam_instance_profile" "riemann_monitoring" {
  name = "riemann-monitoring"
  roles = [
    "${module.cloudwatch_logs_role.name}",
    "${module.riemann_monitoring_role.name}"
  ]
}

resource "aws_iam_instance_profile" "influxdb_monitoring" {
  name = "influxdb-monitoring"
  roles = [
    "${module.cloudwatch_logs_role.name}",
    "${module.influxdb_archive_role.name}"
  ]
}

module "logsearch_ingestor_role" {
  source = "../../modules/iam_role/logsearch_ingestor"
  role_name = "logsearch-ingestor"
  aws_partition = "${var.aws_partition}"
  aws_default_region = "${var.aws_default_region}"
  account_id = "${var.account_id}"
}

module "etcd_backup_role" {
  source = "../../modules/iam_role/etcd_backup"
  role_name = "etcd-backup"
  aws_partition = "${var.aws_partition}"
}

module "cloudwatch_user" {
  source = "../../modules/iam_user/cloudwatch_user"
  username = "bosh-cloudwatch"
}

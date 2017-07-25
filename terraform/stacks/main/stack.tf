terraform {
  backend "s3" {}
}

data "terraform_remote_state" "target_vpc" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "${var.target_stack_name}/terraform.tfstate"
  }
}

module "stack" {
    source = "../../modules/stack/spoke"

    stack_description = "${var.stack_description}"
    aws_partition = "${var.aws_partition}"
    vpc_cidr = "${var.vpc_cidr}"
    aws_default_region = "${var.aws_default_region}"
    public_cidr_1 = "${var.public_cidr_1}"
    public_cidr_2 = "${var.public_cidr_2}"
    private_cidr_1 = "${var.private_cidr_1}"
    private_cidr_2 = "${var.private_cidr_2}"
    rds_private_cidr_1 = "${var.rds_private_cidr_1}"
    rds_private_cidr_2 = "${var.rds_private_cidr_2}"
    restricted_ingress_web_cidrs = "${var.restricted_ingress_web_cidrs}"
    rds_password = "${var.rds_password}"
    account_id = "${var.account_id}"

    target_vpc_id = "${data.terraform_remote_state.target_vpc.vpc_id}"
    target_vpc_cidr = "${data.terraform_remote_state.target_vpc.vpc_cidr}"
    target_bosh_security_group = "${data.terraform_remote_state.target_vpc.bosh_security_group}"
    target_az1_route_table = "${data.terraform_remote_state.target_vpc.private_route_table_az1}"
    target_az2_route_table = "${data.terraform_remote_state.target_vpc.private_route_table_az2}"
    target_monitoring_security_group = "${lookup(data.terraform_remote_state.target_vpc.monitoring_security_groups, var.stack_description)}"
    target_monitoring_security_group_count = "${var.target_monitoring_security_group_count}"
    target_concourse_security_groups = [
      "${data.terraform_remote_state.target_vpc.production_concourse_security_group}",
      "${data.terraform_remote_state.target_vpc.staging_concourse_security_group}"
    ]
    target_concourse_security_group_count = 2
    use_nat_gateway_eip = "${var.use_nat_gateway_eip}"
}

module "cf" {
    source = "../../modules/cloudfoundry"

    account_id = "${var.account_id}"
    stack_description = "${var.stack_description}"
    aws_partition = "${var.aws_partition}"
    elb_main_cert_name = "${var.main_cert_name}"
    elb_apps_cert_name = "${var.apps_cert_name}"
    elb_subnets = "${module.stack.public_subnet_az1},${module.stack.public_subnet_az2}"
    elb_security_groups = "${var.force_restricted_network == "no" ?
      module.stack.web_traffic_security_group :
      module.stack.restricted_web_traffic_security_group}"

    rds_password = "${var.cf_rds_password}"
    rds_subnet_group = "${module.stack.rds_subnet_group}"
    rds_security_groups = "${module.stack.rds_postgres_security_group}"
    stack_prefix = "${var.stack_prefix}"

    vpc_id = "${module.stack.vpc_id}"
    private_route_table_az1 = "${module.stack.private_route_table_az1}"
    private_route_table_az2 = "${module.stack.private_route_table_az2}"
    services_cidr_1 = "${var.services_cidr_1}"
    services_cidr_2 = "${var.services_cidr_2}"
    kubernetes_cluster_id = "${var.kubernetes_cluster_id}"
    bucket_prefix = "${var.bucket_prefix}"
}

module "diego" {
    source = "../../modules/diego"

    stack_description = "${var.stack_description}"
    elb_subnets = "${module.stack.public_subnet_az1},${module.stack.public_subnet_az2}"

    vpc_id = "${module.stack.vpc_id}"
    private_route_table_az1 = "${module.stack.private_route_table_az1}"
    private_route_table_az2 = "${module.stack.private_route_table_az2}"
    stack_description = "${var.stack_description}"
    diego_cidr_1 = "${var.diego_cidr_1}"
    diego_cidr_2 = "${var.diego_cidr_2}"
    ingress_cidrs = "${var.force_restricted_network == "no" ?
      "0.0.0.0/0" :
      "${var.restricted_ingress_web_cidrs}"}"
}

module "kubernetes" {
    source = "../../modules/kubernetes"

    stack_description = "${var.stack_description}"
    aws_default_region = "${var.aws_default_region}"

    vpc_id = "${module.stack.vpc_id}"
    vpc_cidr = "${var.vpc_cidr}"
    tooling_vpc_cidr = "${data.terraform_remote_state.target_vpc.vpc_cidr}"
    elb_subnets = "${module.cf.services_subnet_az1},${module.cf.services_subnet_az2}"
    target_bosh_security_group = "${module.stack.bosh_security_group}"
    target_monitoring_security_group = "${lookup(data.terraform_remote_state.target_vpc.monitoring_security_groups, var.stack_description)}"
    target_concourse_security_group = "${data.terraform_remote_state.target_vpc.production_concourse_security_group}"
}

module "client-elbs" {
    source = "../../modules/client-elbs"

    count = "${var.18f_gov_elb_cert_name == "" ? 0 : 1}"
    stack_description = "${var.stack_description}"

    account_id = "${var.account_id}"
    elb_subnets = "${module.stack.public_subnet_az1},${module.stack.public_subnet_az2}"
    elb_security_groups = "${var.force_restricted_network == "no" ?
      module.stack.web_traffic_security_group :
      module.stack.restricted_web_traffic_security_group}"
    aws_partition = "${var.aws_partition}"
    star_18f_gov_cert_name = "${var.18f_gov_elb_cert_name}"
}

module "shibboleth" {
    source = "../../modules/shibboleth"

    stack_description = "${var.stack_description}"
    elb_subnets = "${module.stack.public_subnet_az1},${module.stack.public_subnet_az2}"

    elb_shibboleth_cert_name = "${var.elb_shibboleth_cert_name}"
    elb_security_groups = "${var.force_restricted_network == "no" ?
      module.stack.web_traffic_security_group :
      module.stack.restricted_web_traffic_security_group}"
    stack_description = "${var.stack_description}"
    account_id = "${var.account_id}"
    aws_partition = "${var.aws_partition}"
}

module "concourse" {
  source = "../../modules/concourse"
  stack_description = "${var.stack_description}"
  aws_partition = "${var.aws_partition}"
  vpc_id = "${module.stack.vpc_id}"
  concourse_cidr = "${var.concourse_cidr}"
  concourse_az = "${var.az2}"
  route_table_id = "${module.stack.private_route_table_az2}"
  rds_password = "${var.concourse_rds_password}"
  rds_subnet_group = "${module.stack.rds_subnet_group}"
  rds_security_groups = "${module.stack.rds_postgres_security_group}"
  rds_instance_type = "db.m3.medium"
  rds_db_iops = 0
  rds_db_storage_type = "gp2"
  rds_db_size = 20
  account_id = "${var.account_id}"
  elb_cert_name = "${var.concourse_elb_cert_name}"
  elb_subnets = "${module.stack.public_subnet_az2}"
  elb_security_groups = "${var.force_restricted_network == "no" ?
    module.stack.web_traffic_security_group :
    module.stack.restricted_web_traffic_security_group}"
}

module "blobstore_policy" {
  source = "../../modules/iam_role_policy/blobstore"
  policy_name = "${var.stack_description}-blobstore"
  aws_partition = "${var.aws_partition}"
  bucket_name = "${var.blobstore_bucket_name}"
}

// Allow development / staging / production bosh to read tooling bosh blobs
module "blobstore_upstream_policy" {
  source = "../../modules/iam_role_policy/blobstore"
  policy_name = "${var.stack_description}-blobstore-upstream"
  aws_partition = "${var.aws_partition}"
  bucket_name = "${var.upstream_blobstore_bucket_name}"
}

module "cloudwatch_policy" {
  source = "../../modules/iam_role_policy/cloudwatch"
  policy_name = "${var.stack_description}-cloudwatch-logs"
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

module "logsearch_ingestor_policy" {
  source = "../../modules/iam_role_policy/logsearch_ingestor"
  policy_name = "${var.stack_description}-logsearch_ingestor"
  aws_partition = "${var.aws_partition}"
  aws_default_region = "${var.aws_default_region}"
  account_id = "${var.account_id}"
}

module "kubernetes_master_policy" {
  source = "../../modules/iam_role_policy/kubernetes_master"
  policy_name = "${var.stack_description}-kubernetes-master"
  aws_partition = "${var.aws_partition}"
}

module "kubernetes_minion_policy" {
  source = "../../modules/iam_role_policy/kubernetes_minion"
  policy_name = "${var.stack_description}-kubernetes-minion"
  aws_partition = "${var.aws_partition}"
}

module "etcd_backup_policy" {
  source = "../../modules/iam_role_policy/etcd_backup"
  policy_name = "${var.stack_description}-etcd-backup"
  aws_partition = "${var.aws_partition}"
  bucket_name = "etcd-*"
}

module "cf_blobstore_policy" {
  source = "../../modules/iam_role_policy/cf_blobstore"
  policy_name = "${var.stack_description}-cf-blobstore"
  aws_partition = "${var.aws_partition}"
  buildpacks_bucket = "${module.cf.buildpacks_bucket_name}"
  packages_bucket = "${module.cf.packages_bucket_name}"
  resources_bucket = "${module.cf.resources_bucket_name}"
  droplets_bucket = "${module.cf.droplets_bucket_name}"
}

module "s3_broker_policy" {
  source = "../../modules/iam_role_policy/s3_broker"
  policy_name = "${var.stack_description}-s3-broker"
  account_id = "${var.account_id}"
  aws_partition = "${var.aws_partition}"
  bucket_prefix = "${var.bucket_prefix}"
  iam_path = "/${var.stack_prefix}/s3/"
}

module "aws_broker_policy" {
  source = "../../modules/iam_role_policy/aws_broker"
  policy_name = "${var.stack_description}-aws-broker"
  account_id = "${var.account_id}"
  aws_partition = "${var.aws_partition}"
  aws_default_region = "${var.aws_default_region}"
  remote_state_bucket = "${var.remote_state_bucket}"
}

module "default_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-default"
}

module "bosh_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-bosh"
}

module "bosh_compilation_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-bosh-compilation"
}

module "logsearch_ingestor_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-logsearch-ingestor"
}

module "kubernetes_master_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-kubernetes-master"
}

module "kubernetes_minion_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-kubernetes-minion"
}

module "etcd_backup_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-etcd-backup"
}

module "cf_blobstore_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-cf-blobstore"
}

module "platform_role" {
  source = "../../modules/iam_role"
  role_name = "${var.stack_description}-platform"
}

resource "aws_iam_policy_attachment" "blobstore" {
  name = "${var.stack_description}-blobstore"
  policy_arn = "${module.blobstore_policy.arn}"
  roles = [
    "${module.default_role.role_name}",
    "${module.bosh_role.role_name}",
    "${module.logsearch_ingestor_role.role_name}",
    "${module.kubernetes_master_role.role_name}",
    "${module.kubernetes_minion_role.role_name}",
    "${module.etcd_backup_role.role_name}",
    "${module.cf_blobstore_role.role_name}",
    "${module.platform_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name = "${var.stack_description}-cloudwatch"
  policy_arn = "${module.cloudwatch_policy.arn}"
  roles = [
    "${module.default_role.role_name}",
    "${module.bosh_role.role_name}",
    "${module.bosh_compilation_role.role_name}",
    "${module.logsearch_ingestor_role.role_name}",
    "${module.kubernetes_master_role.role_name}",
    "${module.kubernetes_minion_role.role_name}",
    "${module.etcd_backup_role.role_name}",
    "${module.cf_blobstore_role.role_name}",
    "${module.platform_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "bosh" {
  name = "${var.stack_description}-bosh"
  policy_arn = "${module.bosh_policy.arn}"
  roles = [
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

resource "aws_iam_policy_attachment" "blobstore_upstream" {
  name = "${var.stack_description}-blobstore-upstream"
  policy_arn = "${module.blobstore_upstream_policy.arn}"
  roles = [
    "${module.bosh_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "logsearch_ingestor" {
  name = "logsearch_ingestor"
  policy_arn = "${module.logsearch_ingestor_policy.arn}"
  roles = [
    "${module.logsearch_ingestor_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "kubernetes_master" {
  name = "${var.stack_description}-kubernetes-master"
  policy_arn = "${module.kubernetes_master_policy.arn}"
  roles = [
    "${module.kubernetes_master_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "kubernetes_minion" {
  name = "${var.stack_description}-kubernetes-minion"
  policy_arn = "${module.kubernetes_minion_policy.arn}"
  roles = [
    "${module.kubernetes_minion_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "ectd_backup" {
  name = "${var.stack_description}-etcd-backup"
  policy_arn = "${module.etcd_backup_policy.arn}"
  roles = [
    "${module.etcd_backup_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "cf_blobstore" {
  name = "${var.stack_description}-cf_blobstore"
  policy_arn = "${module.cf_blobstore_policy.arn}"
  roles = [
    "${module.cf_blobstore_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "s3_broker" {
  name = "${var.stack_description}-s3-broker"
  policy_arn = "${module.s3_broker_policy.arn}"
  roles = [
    "${module.platform_role.role_name}"
  ]
}

resource "aws_iam_policy_attachment" "aws_broker" {
  name = "${var.stack_description}-aws-broker"
  policy_arn = "${module.aws_broker_policy.arn}"
  roles = [
    "${module.platform_role.role_name}"
  ]
}

module "kubernetes_node_role" {
  source = "../../modules/iam_role/kubernetes_node"
  role_name = "${var.stack_description}-kubernetes-node"
  aws_partition = "${var.aws_partition}"
  account_id = "${var.account_id}"
  master_role = "${module.kubernetes_master_role.role_name}"
  minion_role = "${module.kubernetes_minion_role.role_name}"
  assume_role_path = "/bosh-passed/"
}

module "kubernetes_logger_role" {
  source = "../../modules/iam_role/kubernetes_logger"
  role_name = "${var.stack_description}-kubernetes-logger"
  aws_default_region = "${var.aws_default_region}"
  aws_partition = "${var.aws_partition}"
  account_id = "${var.account_id}"
  master_role = "${module.kubernetes_master_role.role_name}"
  minion_role = "${module.kubernetes_minion_role.role_name}"
  assume_role_path = "/bosh-passed/"
}

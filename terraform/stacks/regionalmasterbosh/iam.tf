# Creds for the child boshes (e.g. <region><index>-bosh) to access
# the parent bosh's (e.g. tooling-<region>) blobstore
resource "aws_iam_user" "bosh_blobstore_user" {
  name = "tooling-${var.stack_description}-bosh"
  path = "/bosh/"
}

resource "aws_iam_access_key" "bosh_blobstore_user_key_v1" {
  user    = aws_iam_user.bosh_blobstore_user.name
}
module "s3_logstash" {
  source        = "../../modules/iam_user/s3_logstash"
  username      = "s3-logstash"
  log_bucket    = var.log_bucket_name
  aws_partition = data.aws_partition.current.partition
}

module "rds_storage_alert" {
  source   = "../../modules/iam_user/rds_storage_alert"
  username = "cg-rds-storage-alert"
}

module "iam_cert_provision_user" {
  source        = "../../modules/iam_user/iam_cert_provision"
  username      = "cg-iam-cert-provision"
  aws_partition = data.aws_partition.current.partition
  account_id    = data.aws_caller_identity.current.account_id
}

module "blobstore_policy" {
  source        = "../../modules/iam_role_policy/blobstore"
  policy_name   = "blobstore"
  aws_partition = data.aws_partition.current.partition
  bucket_name   = var.blobstore_bucket_name
}

module "bosh_policy" {
  source        = "../../modules/iam_role_policy/bosh"
  policy_name   = "${var.stack_description}-bosh"
  aws_partition = data.aws_partition.current.partition
  account_id    = data.aws_caller_identity.current.account_id
  bucket_name   = var.blobstore_bucket_name
}

module "bosh_compilation_policy" {
  source        = "../../modules/iam_role_policy/bosh_compilation"
  policy_name   = "${var.stack_description}-bosh-compilation"
  aws_partition = data.aws_partition.current.partition
  bucket_name   = var.blobstore_bucket_name
}

module "cloudwatch_policy" {
  source      = "../../modules/iam_role_policy/cloudwatch"
  policy_name = "${var.stack_description}-cloudwatch"
}

module "self_managed_credentials" {
  source        = "../../modules/iam_role_policy/self_managed_credentials"
  policy_name   = "self-managed-credentials"
  aws_partition = data.aws_partition.current.partition
}

module "compliance_role" {
  source        = "../../modules/iam_role_policy/compliance_role"
  policy_name   = "compliance-role"
  aws_partition = data.aws_partition.current.partition
}

module "default_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-default"
}

module "master_bosh_role" {
  source    = "../../modules/iam_role"
  role_name = "master-bosh"
}

module "bosh_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-bosh"
}

module "bosh_compilation_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-bosh-compilation"
}

resource "aws_iam_policy_attachment" "blobstore" {
  name       = "${var.stack_description}-blobstore"
  policy_arn = module.blobstore_policy.arn

  roles = [
    module.default_role.role_name,
    module.bosh_role.role_name,
  ]
  users = [
    aws_iam_user.bosh_blobstore_user.name
  ]
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name       = "${var.stack_description}-cloudwatch"
  policy_arn = module.cloudwatch_policy.arn

  roles = [
    module.default_role.role_name,
    module.bosh_role.role_name,
    module.bosh_compilation_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "bosh" {
  name       = "${var.stack_description}-bosh"
  policy_arn = module.bosh_policy.arn

  roles = [
    module.master_bosh_role.role_name,
    module.bosh_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "bosh_compilation" {
  name       = "${var.stack_description}-bosh-compilation"
  policy_arn = module.bosh_compilation_policy.arn

  roles = [
    module.bosh_compilation_role.role_name,
  ]
}
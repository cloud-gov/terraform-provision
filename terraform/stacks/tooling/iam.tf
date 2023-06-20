module "billing_user" {
  source         = "../../modules/iam_user/billing_user"
  username       = "cg-billing"
  billing_bucket = "cg-billing-*"
  aws_partition  = data.aws_partition.current.partition
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

# This user has access to all cloudtrail events in the account, as there
# doesn't seem to be a way of constraining to just cloudfront events relevant
# to a set of S3 buckets (or all S3 buckets, for that matter).
#
# If you need cloudtrail auditor access for another reason, PLEASE CREATE A NEW
# USER AND MODULE (yes, even with the same permissions).  Having separate users
# with the same permissions simplifies our work when we have to rotate
# credentials.
module "federalist_auditor_user" {
  source   = "../../modules/iam_user/federalist_auditor"
  username = "federalist-s3-bucket-auditor"
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

module "concourse_worker_policy" {
  source                         = "../../modules/iam_role_policy/concourse_worker"
  policy_name                    = "concourse-worker"
  aws_partition                  = data.aws_partition.current.partition
  varz_bucket                    = var.varz_bucket
  varz_staging_bucket            = var.varz_bucket_stage
  bosh_release_bucket            = var.bosh_release_bucket
  terraform_state_bucket         = var.terraform_state_bucket
  build_artifacts_bucket         = var.build_artifacts_bucket
  semver_bucket                  = var.semver_bucket
  buildpack_notify_bucket        = var.buildpack_notify_bucket
  billing_bucket                 = var.billing_bucket
  cg_binaries_bucket             = var.cg_binaries_bucket
  log_bucket                     = var.log_bucket_name
  concourse_varz_bucket          = var.concourse_varz_bucket
  pgp_keys_bucket_name           = var.pgp_keys_bucket_name
  container_scanning_bucket_name = var.container_scanning_bucket_name
}

module "concourse_iaas_worker_policy" {
  source      = "../../modules/iam_role_policy/concourse_iaas_worker"
  policy_name = "concourse-iaas-worker"
}

module "cloudwatch_policy" {
  source      = "../../modules/iam_role_policy/cloudwatch"
  policy_name = "${var.stack_description}-cloudwatch"
}
module "ecr_policy" {
  source             = "../../modules/iam_role_policy/ecr"
  policy_name        = "ecr"
  aws_partition      = data.aws_partition.current.partition
  aws_default_region = var.aws_default_region
  account_id         = data.aws_caller_identity.current.account_id
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

module "concourse_worker_role" {
  source    = "../../modules/iam_role"
  role_name = "tooling-concourse-worker"
}

module "concourse_iaas_worker_role" {
  source                 = "../../modules/iam_role"
  role_name              = "tooling-concourse-iaas-worker"
  iam_assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS":  "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/bosh-passed/tooling-concourse-iaas-worker",
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "blobstore" {
  name       = "${var.stack_description}-blobstore"
  policy_arn = module.blobstore_policy.arn

  roles = [
    module.default_role.role_name,
    module.bosh_role.role_name,
    module.concourse_worker_role.role_name,
    module.concourse_iaas_worker_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name       = "${var.stack_description}-cloudwatch"
  policy_arn = module.cloudwatch_policy.arn

  roles = [
    module.default_role.role_name,
    module.bosh_role.role_name,
    module.bosh_compilation_role.role_name,
    module.concourse_worker_role.role_name,
    module.concourse_iaas_worker_role.role_name,
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

resource "aws_iam_policy_attachment" "concourse_worker" {
  name       = "concourse_worker"
  policy_arn = module.concourse_worker_policy.arn

  roles = [
    module.concourse_worker_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "concourse_iaas_worker" {
  name       = "concourse_iaas_worker"
  policy_arn = module.concourse_iaas_worker_policy.arn

  roles = [
    module.concourse_iaas_worker_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "ecr" {
  name       = "${var.stack_description}-ecr"
  policy_arn = module.ecr_policy.arn

  roles = [
    module.concourse_worker_role.role_name,
  ]
}

module "ecr_user" {
  source   = "../../modules/iam_user/ecr_user"
  username = "cg-ecr"
}
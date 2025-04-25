resource "aws_iam_user" "s3_broker_user" {
  name = "s3-broker-${var.stack_description}"
}

resource "aws_iam_access_key" "s3_broker_user_key_v3" {
  user = aws_iam_user.s3_broker_user.name
}

resource "aws_iam_user" "logs_opensearch_s3_user" {
  name = "logs-opensearch-s3-${var.stack_description}"
}

resource "aws_iam_access_key" "logs_opensearch_s3_user_key_v3" {
  user = aws_iam_user.logs_opensearch_s3_user.name
}

module "blobstore_policy" {
  source        = "../../modules/iam_role_policy/blobstore"
  policy_name   = "${var.stack_description}-blobstore"
  aws_partition = data.aws_partition.current.partition
  bucket_name   = var.blobstore_bucket_name
}

// Allow development / staging / production bosh to read tooling bosh blobs
module "blobstore_upstream_policy" {
  source        = "../../modules/iam_role_policy/blobstore"
  policy_name   = "${var.stack_description}-blobstore-upstream"
  aws_partition = data.aws_partition.current.partition
  bucket_name   = var.upstream_blobstore_bucket_name
}

module "cloudwatch_policy" {
  source      = "../../modules/iam_role_policy/cloudwatch"
  policy_name = "${var.stack_description}-cloudwatch-logs"
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

module "logsearch_ingestor_policy" {
  source             = "../../modules/iam_role_policy/logsearch_ingestor"
  policy_name        = "${var.stack_description}-logsearch_ingestor"
  aws_partition      = data.aws_partition.current.partition
  aws_default_region = var.aws_default_region
  account_id         = data.aws_caller_identity.current.account_id
}

module "logs_opensearch_ingestor_policy" {
  source             = "../../modules/iam_role_policy/logs_opensearch_ingestor"
  policy_name        = "${var.stack_description}-logs_opensearch_ingestor"
  aws_partition      = data.aws_partition.current.partition
  aws_default_region = var.aws_default_region
  account_id         = data.aws_caller_identity.current.account_id
}

module "logs_opensearch_s3_ingestor_policy" {
  source        = "../../modules/iam_role_policy/logs_opensearch_s3_ingestor"
  policy_name   = "${var.stack_description}-logs_opensearch_s3_ingestor"
  aws_partition = data.aws_partition.current.partition
  aws_default_region = var.aws_default_region
  account_id    = data.aws_caller_identity.current.account_id
}

module "cf_blobstore_policy" {
  source            = "../../modules/iam_role_policy/cf_blobstore"
  policy_name       = "${var.stack_description}-cf-blobstore"
  aws_partition     = data.aws_partition.current.partition
  buildpacks_bucket = module.cf.buildpacks_bucket_name
  packages_bucket   = module.cf.packages_bucket_name
  resources_bucket  = module.cf.resources_bucket_name
  droplets_bucket   = module.cf.droplets_bucket_name
}

module "s3_broker_policy" {
  source        = "../../modules/iam_role_policy/s3_broker"
  policy_name   = "${var.stack_description}-s3-broker"
  account_id    = data.aws_caller_identity.current.account_id
  aws_partition = data.aws_partition.current.partition
  bucket_prefix = var.bucket_prefix
  iam_path      = "/cf-${var.stack_description}/s3/"
}

module "aws_broker_policy" {
  source              = "../../modules/iam_role_policy/aws_broker"
  policy_name         = "${var.stack_description}-aws-broker"
  account_id          = data.aws_caller_identity.current.account_id
  aws_partition       = data.aws_partition.current.partition
  aws_default_region  = var.aws_default_region
  remote_state_bucket = var.remote_state_bucket
  rds_subgroup        = var.stack_description
}

module "elasticache_broker_policy" {
  source      = "../../modules/iam_role_policy/elasticache_broker"
  policy_name = "${var.stack_description}-elasticache-broker"
}

module "default_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-default"
}

module "bosh_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-bosh"
}

module "bosh_compilation_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-bosh-compilation"
}

module "logsearch_ingestor_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-logsearch-ingestor"
}
module "logs_opensearch_ingestor_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-logs-opensearch-ingestor"
}
module "logs_opensearch_ingestor_s3_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-logs-opensearch-ingestor_s3"
}

module "cf_blobstore_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-cf-blobstore"
}

module "platform_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-platform"
}

module "elasticache_broker_role" {
  source    = "../../modules/iam_role"
  role_name = "${var.stack_description}-elasticache-broker"
}

resource "aws_iam_policy_attachment" "blobstore" {
  name       = "${var.stack_description}-blobstore"
  policy_arn = module.blobstore_policy.arn
  roles = [
    module.default_role.role_name,
    module.bosh_role.role_name,
    module.logsearch_ingestor_role.role_name,
    module.logs_opensearch_ingestor_role.role_name,
    module.cf_blobstore_role.role_name,
    module.elasticache_broker_role.role_name,
    module.platform_role.role_name,
    aws_iam_role.domains_broker.name,
  ]
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name       = "${var.stack_description}-cloudwatch"
  policy_arn = module.cloudwatch_policy.arn
  roles = [
    module.default_role.role_name,
    module.bosh_role.role_name,
    module.bosh_compilation_role.role_name,
    module.logsearch_ingestor_role.role_name,
    module.logs_opensearch_ingestor_role.role_name,
    module.cf_blobstore_role.role_name,
    module.elasticache_broker_role.role_name,
    module.platform_role.role_name,
    aws_iam_role.domains_broker.name,
  ]
}


resource "aws_iam_policy_attachment" "bosh" {
  name       = "${var.stack_description}-bosh"
  policy_arn = module.bosh_policy.arn
  roles = [
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

resource "aws_iam_policy_attachment" "blobstore_upstream" {
  name       = "${var.stack_description}-blobstore-upstream"
  policy_arn = module.blobstore_upstream_policy.arn
  roles = [
    module.bosh_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "logsearch_ingestor" {
  name       = "logsearch_ingestor"
  policy_arn = module.logsearch_ingestor_policy.arn
  roles = [
    module.logsearch_ingestor_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "logs_opensearch_ingestor" {
  name       = "logs_opensearch_ingestor"
  policy_arn = module.logs_opensearch_ingestor_policy.arn
  roles = [
    module.logs_opensearch_ingestor_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "logs_opensearch_s3_ingestor" {
  name       = "${var.stack_description}-logs_opensearch_s3_ingestor"
  policy_arn = module.logs_opensearch_s3_ingestor_policy.arn
  roles = [
    module.logs_opensearch_ingestor_s3_role.role_name,
  ]
  users = [
    aws_iam_user.opensearch_s3_ingestor_user.name
  ]
}

resource "aws_iam_policy_attachment" "cf_blobstore" {
  name       = "${var.stack_description}-cf_blobstore"
  policy_arn = module.cf_blobstore_policy.arn
  roles = [
    module.cf_blobstore_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "s3_broker" {
  name       = "${var.stack_description}-s3-broker"
  policy_arn = module.s3_broker_policy.arn
  roles = [
    module.platform_role.role_name,
  ]
  users = [
    aws_iam_user.s3_broker_user.name
  ]
}

resource "aws_iam_policy_attachment" "aws_broker" {
  name       = "${var.stack_description}-aws-broker"
  policy_arn = module.aws_broker_policy.arn
  roles = [
    module.platform_role.role_name,
  ]
}

resource "aws_iam_policy_attachment" "elasticache_broker" {
  name       = "${var.stack_description}-elasticache-broker"
  policy_arn = module.elasticache_broker_policy.arn
  roles = [
    module.elasticache_broker_role.role_name,
  ]
}

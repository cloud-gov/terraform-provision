module "bosh_blobstore_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-bosh-blobstore"
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
}

module "bosh_release_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cloud-gov-bosh-releases"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
  force_destroy = "true"
}

module "billing_bucket_staging" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cg-billing-staging"
  aws_partition = data.aws_partition.current.partition
}

module "billing_bucket_production" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cg-billing-production"
  aws_partition = data.aws_partition.current.partition
}

module "buildpack_notify_state_staging" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-buildpack-notify-state-staging"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

module "buildpack_notify_state_production" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-buildpack-notify-state-production"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

module "cg_binaries_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cg-binaries"
  aws_partition = data.aws_partition.current.partition
}

module "log_bucket" {
  source          = "../../modules/log_bucket_v2"
  aws_partition   = data.aws_partition.current.partition
  log_bucket_name = "${var.bucket_prefix}-cg-elb-logs"
  aws_region      = data.aws_region.current.name
}

module "build_artifacts_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cg-build-artifacts"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

module "pgp_keys_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cg-pgp-keys"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

module "container_scanning_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cg-container-scanning"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}


#Buckets which need to be created for bootstrapping for env.sh:

# TODO: will need to revisit this one to make it match the original bucket permissions
module "varz_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cloud-gov-varz"
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}


# TODO: will need to revisit this one to make it match the original bucket permissions
module "varz_bucket_stage" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cloud-gov-varz-stage"
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}


# TODO: will need to revisit this one to make it match the original bucket permissions
module "semver_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cg-semver"
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}


# TODO: will need to revisit this one to make it match the original bucket permissions
module "concourse_varz_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-concourse-credentials"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}



# TODO: will need to revisit this one to make it match the original bucket permissions
module "cloudtrail_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.bucket_prefix}-cg-s3-cloudtrail"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}


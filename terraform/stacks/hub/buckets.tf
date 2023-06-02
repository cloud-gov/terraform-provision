module "bosh_blobstore_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.blobstore_bucket_name
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
}

module "bosh_release_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.bosh_release_bucket
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
  force_destroy = "true"
}

module "billing_bucket_staging" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "cg-billing-${var.bucket_prefix}-staging"
  aws_partition = data.aws_partition.current.partition
}

module "billing_bucket_production" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "cg-billing-${var.bucket_prefix}-production"
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
  source          = "../../modules/log_bucket"
  aws_partition   = data.aws_partition.current.partition
  log_bucket_name = var.log_bucket_name
  aws_region      = data.aws_region.current.name
}

module "build_artifacts_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.build_artifacts_bucket
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

module "pgp_keys_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.pgp_keys_bucket_name
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

module "container_scanning_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.container_scanning_bucket_name
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}



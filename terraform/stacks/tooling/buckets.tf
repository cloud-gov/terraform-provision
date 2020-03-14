module "bosh_blobstore_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.blobstore_bucket_name}"
  aws_partition = "${data.aws_partition.current.partition}"
  force_destroy = "true"
}

module "bosh_release_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.bosh_release_bucket}"
  aws_partition = "${data.aws_partition.current.partition}"
  versioning    = "true"
  force_destroy = "true"
}

module "billing_bucket_staging" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.bucket_prefix}cg-billing-staging"
  aws_partition = "${data.aws_partition.current.partition}"
}

module "billing_bucket_production" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.bucket_prefix}cg-billing-production"
  aws_partition = "${data.aws_partition.current.partition}"
}

module "buildpack_notify_state_staging" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.bucket_prefix}buildpack-notify-state-staging"
  aws_partition = "${data.aws_partition.current.partition}"
  versioning    = "true"
}

module "buildpack_notify_state_production" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.bucket_prefix}buildpack-notify-state-production"
  aws_partition = "${data.aws_partition.current.partition}"
  versioning    = "true"
}

module "cg_binaries_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.bucket_prefix}cg-binaries"
  aws_partition = "${data.aws_partition.current.partition}"
}

module "log_bucket" {
  source          = "../../modules/log_bucket"
  aws_partition   = "${data.aws_partition.current.partition}"
  log_bucket_name = "${var.log_bucket_name}"
  aws_region      = "${data.aws_region.current.name}"
}

module "build_artifacts_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "cg-build-artifacts"
  aws_partition = "${data.aws_partition.current.partition}"
  versioning    = "true"
}

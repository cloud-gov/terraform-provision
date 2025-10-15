module "bosh_blobstore_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_description}-bosh-blobstore"
  aws_partition = data.aws_partition.current.partition
  # force_destroy = "true"
}

module "bosh_release_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_description}-cloud-gov-bosh-releases"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
  # force_destroy = "true"
}

module "billing_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_description}-cg-billing"
  aws_partition = data.aws_partition.current.partition
}

# module "billing_bucket_staging" {
#   source        = "../../modules/s3_bucket/encrypted_bucket"
#   bucket        = "${var.stack_description}-cg-billing-staging"
#   aws_partition = data.aws_partition.current.partition
# }

# module "billing_bucket_production" {
#   source        = "../../modules/s3_bucket/encrypted_bucket"
#   bucket        = "${var.stack_description}-cg-billing-production"
#   aws_partition = data.aws_partition.current.partition
# }

module "buildpack_notify_state" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_description}-buildpack-notify-state"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

# module "buildpack_notify_state_staging" {
#   source        = "../../modules/s3_bucket/encrypted_bucket"
#   bucket        = "${var.stack_description}-buildpack-notify-state-staging"
#   aws_partition = data.aws_partition.current.partition
#   versioning    = "true"
# }

# module "buildpack_notify_state_production" {
#   source        = "../../modules/s3_bucket/encrypted_bucket"
#   bucket        = "${var.stack_description}-buildpack-notify-state-production"
#   aws_partition = data.aws_partition.current.partition
#   versioning    = "true"
# }

module "cg_binaries_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_description}-cg-binaries"
  aws_partition = data.aws_partition.current.partition
}

module "log_bucket" {
  source                   = "../../modules/log_bucket"
  aws_partition            = data.aws_partition.current.partition
  log_bucket_name          = "${var.stack_description}-cg-elb-logs"
  aws_region               = data.aws_region.current.region
  log_bucket_force_destroy = false
}

module "build_artifacts_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_description}-cg-build-artifacts"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

module "container_scanning_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_description}-cg-container-scanning"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}



# module "protobosh_blobstore_bucket" {
#   source        = "../../modules/s3_bucket/encrypted_bucket_v2"
#   bucket        = "${var.stack_description}-protobosh-blobstore"
#   aws_partition = data.aws_partition.current.partition
# }

# # Removed from tooling on branch main
# # module "pgp_keys_bucket" {
# #   source        = "../../modules/s3_bucket/encrypted_bucket_v2"
# #   bucket        = "${var.stack_description}-cg-pgp-keys"
# #   aws_partition = data.aws_partition.current.partition
# #   versioning    = "true"
# # }

# #Buckets which need to be created for bootstrapping, not originally part of this stack

# Existing is a private bucket requiring AES256 encryption
module "varz_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.stack_description}-cloud-gov-varz"
  aws_partition = data.aws_partition.current.partition
  # force_destroy = "true"
  versioning = "true"
}

# # Existing is a private bucket requiring AES256 encryption
# module "varz_bucket_stage" {
#   source        = "../../modules/s3_bucket/encrypted_bucket_v2"
#   bucket        = "${var.stack_description}-cloud-gov-varz-stage"
#   aws_partition = data.aws_partition.current.partition
#   # force_destroy = "true"
#   versioning = "true"
# }

# Existing is a private bucket requiring AES256 encryption
module "concourse_varz_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.stack_description}-concourse-credentials"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

# Creating a whole new module for this one
module "semver_bucket" {
  source        = "../../modules/s3_bucket/semver_bucket"
  bucket        = "${var.stack_description}-cg-semver"
  aws_partition = data.aws_partition.current.partition
}

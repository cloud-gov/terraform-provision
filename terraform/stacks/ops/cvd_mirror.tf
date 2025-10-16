# V2 is required b/c ACLs are disabled by default
module "cvd_meta_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "${var.stack_description}-cg-clamav-meta"
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
}

# V2 is required b/c ACLs are disabled by default
module "cvd_database_bucket" {
  source        = "../../modules/cvd_mirror_v2"
  bucket        = "${var.stack_description}-cg-clamav-mirror"
  aws_partition = data.aws_partition.current.partition
  versioning    = "false"
}

module "cvd_sync_user" {
  source              = "../../modules/iam_user/cvd_sync"
  username            = "clamav_mirror_sync"
  cvd_database_bucket = "${var.stack_description}-cg-clamav-mirror"
  cvd_metadata_bucket = "${var.stack_description}-cg-clamav-meta"
  aws_partition       = data.aws_partition.current.partition
}

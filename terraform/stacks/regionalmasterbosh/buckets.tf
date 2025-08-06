module "bosh_blobstore_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = var.blobstore_bucket_name
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
}

module "bosh_release_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = var.bosh_release_bucket
  aws_partition = data.aws_partition.current.partition
  versioning    = "true"
  force_destroy = "true"
}

module "log_bucket" {
  source          = "../../modules/log_bucket"
  aws_partition   = data.aws_partition.current.partition
  log_bucket_name = var.log_bucket_name
  aws_region      = data.aws_region.current.region
}

#Buckets which need to be created for bootstrapping for env.sh:
data "aws_partition" "current" {
}


module "varz_blobstore_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = var.varz_bucket_name
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}
module "semver_blobstore_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = var.semver_bucket_name
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}

module "bosh_releases_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = var.bosh_releases_bucket_name
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}


module "bosh_releases_blobstore_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket"
  bucket        = var.bosh_releases_blobstore_bucket_name
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}




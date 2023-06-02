#Buckets which need to be created for bootstrapping for env.sh:
data "aws_partition" "current" {
}

# TODO: will need to revisit this one to make it match the original bucket permissions
module "varz_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.varz_bucket
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}


# TODO: will need to revisit this one to make it match the original bucket permissions
module "varz_bucket_staging" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.varz_bucket_stage
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}


# TODO: will need to revisit this one to make it match the original bucket permissions
module "semver_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.semver_bucket_name
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}




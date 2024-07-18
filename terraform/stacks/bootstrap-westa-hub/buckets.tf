#Buckets which need to be created for bootstrapping for env.sh:
data "aws_partition" "current" {
}


module "tfstate_bucket" {
  source        = "../../modules/s3_bucket/encrypted_bucket_v2"
  bucket        = var.tfstate_bucket_name
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
  versioning    = "true"
}

module "bosh_blobstore_bucket" {
  source                 = "../../modules/s3_bucket/encrypted_bucket"
  bucket                 = var.blobstore_bucket_name
  aws_partition          = data.aws_partition.current.partition
  force_destroy          = "true"
  server_side_encryption = var.bosh_blobstore_sse
}

module "log_bucket" {
  source          = "../../modules/log_bucket"
  aws_partition   = data.aws_partition.current.partition
  log_bucket_name = "${var.stack_description}-elb-logs"
  aws_region      = data.aws_region.current.region
}

module "falco_blobstore_bucket" {
  count         = var.falco_bucket ? 1 : 0
  source        = "../../modules/s3_bucket/log_encrypted_bucket_v3"
  bucket        = "logs-opensearch-falco-${var.stack_description}"
  aws_partition = data.aws_partition.current.partition
  force_destroy = "true"
}

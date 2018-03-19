module "bosh_blobstore_bucket" {
  source = "../../modules/s3_bucket/encrypted_bucket"
  bucket = "${var.blobstore_bucket_name}"
  aws_partition = "${local.aws_partition}"
  force_destroy = "true"
}

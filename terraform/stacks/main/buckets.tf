module "bosh_blobstore_bucket" {
  source = "../../modules/s3_bucket/encrypted_bucket"
  bucket = "${var.blobstore_bucket_name}"
  aws_partition = "${data.aws_partition.current.partition}"
  force_destroy = "true"
}

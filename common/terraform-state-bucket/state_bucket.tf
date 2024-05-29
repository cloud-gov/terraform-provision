module "bosh-resources" {
  source = "github.com/cloud-gov/cg-provision//terraform/modules/s3_bucket/encrypted_bucket_v2"
  bucket        = "common-terraform-state"
  aws_partition = data.aws_partition.current.id
}

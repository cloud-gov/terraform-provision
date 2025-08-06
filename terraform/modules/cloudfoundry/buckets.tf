module "cc-resoures" {
  source        = "../s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_prefix}-cc-resources"
  aws_partition = var.aws_partition
}

module "buildpacks" {
  source        = "../s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_prefix}-buildpacks"
  aws_partition = var.aws_partition
}

module "cc-packages" {
  source        = "../s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_prefix}-cc-packages"
  aws_partition = var.aws_partition
}

module "droplets" {
  source        = "../s3_bucket/encrypted_bucket"
  bucket        = "${var.stack_prefix}-droplets"
  aws_partition = var.aws_partition
}

module "logsearch-archive" {
  source           = "../s3_bucket/log_encrypted_bucket"
  bucket           = "logsearch-${var.stack_prefix}"
  aws_partition    = var.aws_partition
  expiration_days  = 930 # 31 days * 30 months = 930 days
  acl              = "private"
  object_ownership = "ObjectWriter"
}

module "logs-opensearch-archive" {
  source           = "../s3_bucket/log_encrypted_bucket"
  bucket           = "logs-opensearch-${var.stack_prefix}"
  aws_partition    = var.aws_partition
  expiration_days  = 930 # 31 days * 30 months = 930 days
  acl              = "private"
  object_ownership = "ObjectWriter"
}

module "logs-opensearch-cf-audit-events" {
  source          = "../s3_bucket/log_encrypted_bucket"
  bucket          = "logs-opensearch-cf-audit-events-${var.stack_prefix}"
  aws_partition   = var.aws_partition
  expiration_days = 930 # 31 days * 30 months = 930 days
}

module "logs-opensearch-aws-metrics" {
  source          = "../s3_bucket/log_encrypted_bucket"
  bucket          = "logs-opensearch-aws-metrics-${var.stack_prefix}"
  aws_partition   = var.aws_partition
  expiration_days = 930 # 31 days * 30 months = 930 days
}

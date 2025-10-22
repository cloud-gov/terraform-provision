locals {
  common_tags = merge(
    var.tags,
    {
      Module = "cloudwatch_s3_ingestor"
    }
  )
}
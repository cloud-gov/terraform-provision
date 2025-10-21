locals {
  common_tags = merge(
    var.tags,
    {
      Module = "cloudwatch_processing_lambda"
    }
  )
}
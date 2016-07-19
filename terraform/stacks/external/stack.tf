module "cdn_broker" {
    source = "../../modules/cdn_broker"

    account_id = "${var.account_id}"
    stack_description = "${var.stack_description}"
    aws_partition = "${var.aws_partition}"
    username = "${var.cdn_broker_username}"
    bucket = "${var.cdn_broker_bucket}"
    cloudfront_prefix = "${var.cdn_broker_cloudfront_prefix}"
}

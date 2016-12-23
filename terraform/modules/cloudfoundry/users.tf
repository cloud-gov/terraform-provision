module "s3_broker_user" {
  source = "../iam_user/go_s3_broker_user"
  username = "s3-broker-${var.stack_prefix}"
  account_id = "${var.account_id}"
  aws_partition = "${var.aws_partition}"
  bucket_prefix = "${var.bucket_prefix}"
  iam_path = "/${var.stack_prefix}/s3/"
}

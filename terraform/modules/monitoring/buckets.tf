module "influxdb-archive" {
    source = "../s3_bucket/encrypted_bucket"
    bucket = "influxdb-${var.stack_description}"
    aws_partition = "${var.aws_partition}"
    expiration_days = 548
}

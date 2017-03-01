module "cdn_broker_bucket" {
  source = "../../s3_bucket/public_encrypted_bucket"
  bucket = "${var.bucket}"
  aws_partition = "${var.aws_partition}"
}

data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    aws_partition = "${var.aws_partition}"
    account_id = "${var.account_id}"
    cloudfront_prefix = "${var.cloudfront_prefix}"
    hosted_zone = "${var.hosted_zone}"
    bucket = "${var.bucket}"
  }
}

module "cdn_broker_user" {
  source = ".."

  username = "${var.username}"
  iam_policy = "${data.template_file.policy.rendered}"
}

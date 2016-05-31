module "bootstrap_concourse" {
  source = "../../modules/bootstrap_concourse"

  concourse_password = "${var.concourse_password}"
  aws_access_key_id = "${var.aws_access_key_id}"
  aws_secret_access_key = "${var.aws_secret_access_key}"
  credentials_bucket = "${var.credentials_bucket}"
  aws_default_region = "${var.aws_default_region}"
}

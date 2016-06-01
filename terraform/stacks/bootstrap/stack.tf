module "bootstrap_concourse" {
  source = "../../modules/bootstrap_concourse"

  concourse_password = "${var.concourse_password}"
  aws_access_key_id = "${var.aws_access_key_id}"
  aws_secret_access_key = "${var.aws_secret_access_key}"
  account_id = "${var.account_id}"
  remote_state_bucket = "${var.remote_state_bucket}"
  credentials_bucket = "${var.credentials_bucket}"
  aws_default_region = "${var.aws_default_region}"
  default_vpc_id = "${var.default_vpc_id}"
  default_vpc_cidr = "${var.default_vpc_cidr}"
  default_vpc_route_table = "${var.default_vpc_route_table}"
}

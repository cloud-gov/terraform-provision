module "bootstrap_concourse" {
  source = "../../modules/bootstrap_concourse"

  concourse_password = "${var.concourse_password}"
  region = "${var.default_region}"
}

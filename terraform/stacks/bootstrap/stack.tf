module "bootstrap_concourse" {
  source = "../../modules/bootstrap_concourse"

  concourse_password = "${var.concourse_password}"
  aws_access_key_id = "${var.aws_access_key_id}"
  aws_secret_access_key = "${var.aws_secret_access_key}"
  account_id = "${var.account_id}"
  instance_type = "${var.instance_type}"
  remote_state_bucket = "${var.remote_state_bucket}"
  credentials_bucket = "${var.credentials_bucket}"
  aws_default_region = "${var.aws_default_region}"
  default_vpc_id = "${var.default_vpc_id}"
  default_vpc_cidr = "${var.default_vpc_cidr}"
  default_vpc_route_table = "${var.default_vpc_route_table}"
  ami_id = "${var.ami_id}"
}

module "bootstrap_buckets" {
    source = "../../modules/bootstrap_buckets"
    aws_partition = "${var.aws_partition}"

    varz_bucket = "${var.varz_bucket}"
    varz_staging_bucket = "${var.varz_staging_bucket}"
    credentials_bucket = "${var.credentials_bucket}"
    tooling_blobstore_bucket = "${var.tooling_blobstore_bucket}"
    staging_blobstore_bucket = "${var.staging_blobstore_bucket}"
    production_blobstore_bucket = "${var.production_blobstore_bucket}"
    bosh_release_bucket = "${var.bosh_release_bucket}"
    stemcell_bucket = "${var.stemcell_bucket}"
}

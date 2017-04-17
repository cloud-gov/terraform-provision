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
}

module "bootstrap_buckets" {
  source = "../../modules/bootstrap_buckets"
  aws_partition = "${var.aws_partition}"

  varz_bucket = "cloud-gov-varz"
  varz_staging_bucket = "cloud-gov-varz-staging"
  concourse_credentials_bucket = "concourse-credentials"
  tooling_blobstore_bucket = "bosh-tooling-blobstore"
  development_blobstore_bucket = "bosh-development-blobstore"
  staging_blobstore_bucket = "bosh-staging-blobstore"
  production_blobstore_bucket = "bosh-prod-blobstore"
  bosh_release_bucket = "cloud-gov-bosh-releases"
  stemcell_bucket = "cg-stemcell-images"
  tmp_bucket = "cloud-gov-tmp"
}

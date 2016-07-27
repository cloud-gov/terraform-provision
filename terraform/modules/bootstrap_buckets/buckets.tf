module "varz" {
    source = "../s3_bucket/encrypted_bucket"
    bucket = "${var.varz_bucket}"
    aws_partition = "${var.aws_partition}"
    versioning = "true"
}

module "varz_staging" {
    source = "../s3_bucket/encrypted_bucket"
    bucket = "${var.varz_staging_bucket}"
    aws_partition = "${var.aws_partition}"
    versioning = "true"
}

module "concourse_credentials" {
    source = "../s3_bucket/encrypted_bucket"
    bucket = "${var.credentials_bucket}"
    aws_partition = "${var.aws_partition}"
    versioning = "true"
}

/* TODO: Enable after https://github.com/cloudfoundry/bosh/commit/d473e74ccf9df32e2b38cef0ff40ce1616a3195b#diff-a711787c2157fb23b45c5890b26b9f7d is released
module "tooling_blobstore" {
    source = "../s3_bucket/public_encrypted_bucket"
    bucket = "${var.tooling_blobstore_bucket}"
    aws_partition = "${var.aws_partition}"
}

module "staging_blobstore" {
    source = "../s3_bucket/public_encrypted_bucket"
    bucket = "${var.staging_blobstore_bucket}"
    aws_partition = "${var.aws_partition}"
}

module "production_blobstore" {
    source = "../s3_bucket/public_encrypted_bucket"
    bucket = "${var.production_blobstore_bucket}"
    aws_partition = "${var.aws_partition}"
}
*/

/* TODO: Enable after https://github.com/concourse/s3-resource/pull/43 is merged
module "bosh_release" {
    source = "../s3_bucket/encrypted_bucket"
    bucket = "${var.bosh_release_bucket}"
    aws_partition = "${var.aws_partition}"
    versioning = "true"
}

module "stemcell_images" {
    source = "../s3_bucket/encrypted_bucket"
    bucket = "${var.stemcell_bucket}"
    aws_partition = "${var.aws_partition}"
    versioning = "true"
}
*/

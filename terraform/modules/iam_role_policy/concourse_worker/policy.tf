data "template_file" "policy" {
  template = file("${path.module}/policy.json")

  vars = {
    aws_partition                       = var.aws_partition
    varz_bucket                         = var.varz_bucket
    varz_staging_bucket                 = var.varz_staging_bucket
    bosh_release_bucket                 = var.bosh_release_bucket
    build_artifacts_bucket              = var.build_artifacts_bucket
    terraform_state_bucket              = var.terraform_state_bucket
    semver_bucket                       = var.semver_bucket
    buildpack_notify_bucket             = var.buildpack_notify_bucket
    billing_bucket                      = var.billing_bucket
    cg_binaries_bucket                  = var.cg_binaries_bucket
    log_bucket                          = var.log_bucket
    concourse_varz_bucket               = var.concourse_varz_bucket
    pgp_keys_bucket_name                = var.pgp_keys_bucket_name
    container_scanning_bucket_name      = var.container_scanning_bucket_name
    tooling_credhub_backups_bucket_name = var.tooling_credhub_backups_bucket_name
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.template_file.policy.rendered
}


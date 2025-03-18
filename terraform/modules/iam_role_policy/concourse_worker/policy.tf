data "aws_iam_policy_document" "concourse_worker_policy" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketNotification",
      "s3:GetBucketPolicy",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.varz_bucket}",
      "arn:${var.aws_partition}:s3:::${var.varz_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.varz_staging_bucket}",
      "arn:${var.aws_partition}:s3:::${var.varz_staging_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.bosh_release_bucket}",
      "arn:${var.aws_partition}:s3:::${var.bosh_release_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.terraform_state_bucket}",
      "arn:${var.aws_partition}:s3:::${var.terraform_state_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.billing_bucket}",
      "arn:${var.aws_partition}:s3:::${var.billing_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.semver_bucket}",
      "arn:${var.aws_partition}:s3:::${var.semver_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.log_bucket}",
      "arn:${var.aws_partition}:s3:::${var.log_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.buildpack_notify_bucket}",
      "arn:${var.aws_partition}:s3:::${var.buildpack_notify_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.cg_binaries_bucket}",
      "arn:${var.aws_partition}:s3:::${var.cg_binaries_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.build_artifacts_bucket}",
      "arn:${var.aws_partition}:s3:::${var.build_artifacts_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.concourse_varz_bucket}",
      "arn:${var.aws_partition}:s3:::${var.concourse_varz_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.container_scanning_bucket_name}",
      "arn:${var.aws_partition}:s3:::${var.container_scanning_bucket_name}/*",
      "arn:${var.aws_partition}:s3:::${var.github_backups_bucket_name}",
      "arn:${var.aws_partition}:s3:::${var.github_backups_bucket_name}/*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.semver_bucket}",
      "arn:${var.aws_partition}:s3:::${var.semver_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.log_bucket}",
      "arn:${var.aws_partition}:s3:::${var.log_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.buildpack_notify_bucket}",
      "arn:${var.aws_partition}:s3:::${var.buildpack_notify_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.billing_bucket}",
      "arn:${var.aws_partition}:s3:::${var.billing_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.varz_bucket}/*-bosh-state.json",
      "arn:${var.aws_partition}:s3:::${var.varz_bucket}/*-creds.yml",
      "arn:${var.aws_partition}:s3:::${var.build_artifacts_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.terraform_state_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.github_backups_bucket_name}/*",
      "arn:${var.aws_partition}:s3:::${var.container_scanning_bucket_name}",
      "arn:${var.aws_partition}:s3:::${var.container_scanning_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.concourse_worker_policy.json
}

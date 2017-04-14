module "concourse" {
  source = ".."

  role_name = "${var.role_name}"
  iam_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
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
      ],
      "Resource": [
        "arn:${var.aws_partition}:s3:::${var.varz_bucket}",
        "arn:${var.aws_partition}:s3:::${var.varz_bucket}/*",
        "arn:${var.aws_partition}:s3:::${var.varz_staging_bucket}",
        "arn:${var.aws_partition}:s3:::${var.varz_staging_bucket}/*",
        "arn:${var.aws_partition}:s3:::${var.varz_development_bucket}",
        "arn:${var.aws_partition}:s3:::${var.varz_development_bucket}/*",
        "arn:${var.aws_partition}:s3:::${var.bosh_release_bucket}",
        "arn:${var.aws_partition}:s3:::${var.bosh_release_bucket}/*",
        "arn:${var.aws_partition}:s3:::${var.stemcell_bucket}",
        "arn:${var.aws_partition}:s3:::${var.stemcell_bucket}/*",
        "arn:${var.aws_partition}:s3:::${var.terraform_state_bucket}",
        "arn:${var.aws_partition}:s3:::${var.terraform_state_bucket}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersionAcl"
      ],
      "Resource": [
        "arn:${var.aws_partition}:s3:::${var.varz_bucket}/master-bosh-state.json",
        "arn:${var.aws_partition}:s3:::${var.terraform_state_bucket}/*"
      ]
    }
  ]
}
EOF
}

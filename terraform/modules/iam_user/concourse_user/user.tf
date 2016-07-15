
module "concourse_user" {
    source = ".."

    username = "${var.username}"

    /* TODO: Make the bucket names configurable */
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
                "arn:${var.aws_partition}:s3:::${var.prod_private_bucket}",
                "arn:${var.aws_partition}:s3:::${var.prod_private_bucket}/*",
                "arn:${var.aws_partition}:s3:::${var.staging_private_bucket}",
                "arn:${var.aws_partition}:s3:::${var.staging_private_bucket}/*",
                "arn:${var.aws_partition}:s3:::${var.bosh_releases_bucket}",
                "arn:${var.aws_partition}:s3:::${var.bosh_releases_bucket}/*",
                "arn:${var.aws_partition}:s3:::${var.cg-stemcell-images}",
                "arn:${var.aws_partition}:s3:::${var.cg-stemcell-images}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:${var.aws_partition}:s3:::${var.prod_private_bucket}/master-bosh-state.json"
            ]
        }
    ]
}
EOF
}

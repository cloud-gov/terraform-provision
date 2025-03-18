data "aws_iam_policy_document" "cf_blobstore_policy" {
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
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${var.buildpacks_bucket}",
      "arn:${var.aws_partition}:s3:::${var.buildpacks_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.packages_bucket}",
      "arn:${var.aws_partition}:s3:::${var.packages_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.resources_bucket}",
      "arn:${var.aws_partition}:s3:::${var.resources_bucket}/*",
      "arn:${var.aws_partition}:s3:::${var.droplets_bucket}",
      "arn:${var.aws_partition}:s3:::${var.droplets_bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.cf_blobstore_policy.json
}

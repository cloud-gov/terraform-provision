
module "cf_user" {
    source = ".."

    username = "${var.username}"

    /* TODO: Make the bucket names configurable */
    /* TODO: Make sure the bucket arn:path is configurable */
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
                "s3:ListMultipartUploadParts",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws-us-gov:s3:::cf-production-buildpacks",
                "arn:aws-us-gov:s3:::cf-production-buildpacks/*",
                "arn:aws-us-gov:s3:::cf-staging-buildpacks",
                "arn:aws-us-gov:s3:::cf-staging-buildpacks/*",
                "arn:aws-us-gov:s3:::cf-production-cc-packages",
                "arn:aws-us-gov:s3:::cf-production-cc-packages/*",
                "arn:aws-us-gov:s3:::cf-staging-cc-packages",
                "arn:aws-us-gov:s3:::cf-staging-cc-packages/*",
                "arn:aws-us-gov:s3:::cf-production-cc-resources",
                "arn:aws-us-gov:s3:::cf-production-cc-resources/*",
                "arn:aws-us-gov:s3:::cf-staging-cc-resources",
                "arn:aws-us-gov:s3:::cf-staging-cc-resources/*",
                "arn:aws-us-gov:s3:::cf-production-droplets",
                "arn:aws-us-gov:s3:::cf-production-droplets/*",
                "arn:aws-us-gov:s3:::cf-staging-droplets",
                "arn:aws-us-gov:s3:::cf-staging-droplets/*"

            ]
        }
    ]
}
EOF
}
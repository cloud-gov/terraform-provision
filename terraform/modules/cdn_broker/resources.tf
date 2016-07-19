module "cdn_broker_bucket" {
    source = "../s3_bucket/encrypted_public_bucket"
    bucket = "${var.bucket}"
    aws_partition = "${var.aws_partition}"
}

module "cdn_broker_user" {
    source = "../iam_user"

    username = "${var.username}"

    iam_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "manageIamCerts",
            "Effect": "Allow",
            "Action": [
                "iam:DeleteServerCertificate",
                "iam:ListServerCertificates",
                "iam:UploadServerCertificate",
                "iam:UpdateServerCertificate"
            ],
            "Resource": [
                "arn:{$var.aws_partition}:iam::${var.account_id}:server-certificate/cloudfront/${var.cloudfront_prefix}"
            ]
        },
        {
            "Sid": "manageCloudfront",
            "Effect": "Allow",
            "Action": "cloudfront:*",
            "Resource": "*"
        },
        {
            "Sid": "manageS3",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:${var.aws_partition}:s3:::${var.bucket}/*"
            ]
        }
    ]
}
EOF
}

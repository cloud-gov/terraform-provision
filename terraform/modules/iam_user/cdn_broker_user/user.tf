
module "cdn_broker_user" {
    source = ".."

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
                "arn:aws:iam::${var.account_id}:server-certificate/cloudfront/cg/*"
            ]
        },
        {
            "Sid": "manageCloudfront",
            "Effect": "Allow",
            "Action": [
                "cloudfront:*"
            ],
            "Resource": [
                "*"
            ]
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
                "arn:aws:s3:::${aws_s3_bucket.cdn_broker_le.id}/*"
            ]
        }
    ]
}
EOF
}

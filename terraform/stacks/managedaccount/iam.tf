provider "aws" {
  use_fips_endpoint = true
  default_tags {
    tags = {
      deployment = "managed-account-${var.environment_name}"
      stack      = "${var.environment_name}"
    }
  }
}

resource "aws_iam_role" "tfrole" {
  name        = "${var.environment_name}-tooling-concourse-worker"
  path        = "/terraform/"
  description = "policy to allow terraform to run from tooling"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.tf_remote_role_arn
        }
      },
    ]
  })

}

resource "aws_iam_policy" "tfpolicy" {
  name = "${var.environment_name}-tooling-terraform-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "tfrolepolicy" {
  role       = aws_iam_role.tfrole.name
  policy_arn = aws_iam_policy.tfpolicy.arn
}

resource "aws_iam_role" "certuploadrole" {
  name        = "${var.environment_name}-tooling-cert-uploader"
  path        = "/terraform/"
  description = "policy to allow terraform to run from tooling"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.cert_remote_role_arn
        }
      },
    ]
  })

}
data "aws_partition" "current" {

}

data "aws_caller_identity" "current" {

}
resource "aws_iam_policy" "certuploadpolicy" {
  name = "${var.environment_name}-tooling-cert-uploader-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListServerCertificates",
          "iam:UploadServerCertificate",
          "iam:DeleteServerCertificate"
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/lets-encrypt/*"
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "certuploadrolepolicy" {
  role       = aws_iam_role.certuploadrole.name
  policy_arn = aws_iam_policy.certuploadpolicy.arn
}
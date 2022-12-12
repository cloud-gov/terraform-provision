variable "kms_account_id" {
  type = string
  description = "Account ID making requests to KMS key"
}

variable "acl" {
  type = string
  description = "ACL to apply to objects"
  default = "private"
}

variable "bucket_name" {
  type = string
  description = "Name of S3 bucket"
}

variable "region" {
  type = string
  description = "AWS region (e.g. us-gov-west-1)"
}
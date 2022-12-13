variable "acl" {
  type = string
  description = "ACL to apply to objects"
  default = "private"
}

variable "aws_partition" {
  type = string
  description = "Name of AWS partition (e.g. aws)"
}

variable "bucket_name" {
  type = string
  description = "Name of S3 bucket"
}

variable "enable_bucket_versioning" {
  type = bool
  description = "true to enable versioning of objects stored in bucket"
}

variable "kms_account_id" {
  type = string
  description = "Account ID making requests to KMS key"
}

variable "kms_admin_roles" {
  type = list(string)
  default = ["Administrator"]
}

variable "lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
  # Example:
  #
  # lifecycle_rules = [
  #   {
  #     id      = "log"
  #     status = "Enabled"
  #
  #     prefix = "log/"
  #
  #     transition = [
  #       {
  #         days          = 30
  #         storage_class = "STANDARD_IA"
  #       },
  #       {
  #         days          = 60
  #         storage_class = "GLACIER"
  #       }
  #     ]
  #
  #     expiration = {
  #       days = 90
  #     }
  #   }
  # ]
}

variable "region" {
  type = string
  description = "AWS region (e.g. us-gov-west-1)"
}
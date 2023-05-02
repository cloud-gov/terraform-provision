variable "acl" {
  type        = string
  description = "ACL to apply to objects"
}

variable "aws_partition" {
  type        = string
  description = "Name of AWS partition (e.g. aws)"
}

variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket"
}

variable "enable_bucket_versioning" {
  type        = bool
  description = "true to enable versioning of objects stored in bucket"
}

variable "kms_account_id" {
  type        = string
  description = "Account ID making requests to KMS key"
}

variable "kms_admin_roles" {
  type    = list(string)
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

variable "allowed_external_account_ids" {
  type    = list(string)
  default = []
}

variable "region" {
  type        = string
  description = "AWS region (e.g. us-gov-west-1)"
}

variable "source_bucket_policy_documents" {
  description = "IAM policy documents to include in the S3 bucket policy"
  type        = list(string)
  default     = []
}

variable "source_kms_key_policy_documents" {
  description = "IAM policy documents to include in the KMS key policy"
  type        = list(string)
  default     = []
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  default     = false
}

variable "object_ownership" {
  type = string
  default = "BucketOwnerPreferred"
}

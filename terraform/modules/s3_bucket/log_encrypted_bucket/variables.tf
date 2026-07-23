variable "bucket" {
}

variable "acl" {
  default = ""
}

variable "versioning" {
  default = "false"
}

variable "force_destroy" {
  default = "false"
}

variable "aws_partition" {
}

variable "expiration_days" {
  default = 0
}

variable "transition_storage_class" {
  description = "Storage class to transition objects to via the lifecycle rule"
  type        = string
  default     = "GLACIER_IR"
}

variable "transition_days" {
  description = "Number of days after which objects transition to transition_storage_class"
  type        = number
  default     = 90
}

variable "include_require_encrypted_put_bucket_policy" {
  description = "True to include bucket policy to required encrypted PUTs"
  type        = bool
  default     = true
}

variable "source_bucket_policy_documents" {
  description = "IAM policy documents to include in the S3 bucket policy"
  type        = list(string)
  default     = []
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  default     = true
}

variable "object_ownership" {
  type        = string
  default     = "BucketOwnerPreferred"
  description = "Object ownership strategy to use for S3 bucket"
}

variable "access_logging_target_bucket" {
  type        = string
  default     = ""
  description = "Target S3 bucket name to use for access logging of bucket created by this module"
}

variable "access_logging_target_bucket_prefix" {
  type        = string
  default     = ""
  description = "Prefix to use when writing access logs of bucket created by this module. Requires access_logging_target_bucket to be set."
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 1
  description = "How many days to wait after S3 bucket versions become noncurrent before deleting them"
}

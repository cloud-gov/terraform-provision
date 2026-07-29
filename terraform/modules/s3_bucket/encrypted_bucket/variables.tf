variable "bucket" {
}

variable "acl" {
  default = "private"
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

variable "server_side_encryption" {
  default = "AES256"
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 1
  description = "How many days to wait after S3 bucket versions become noncurrent before deleting them"
}

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

variable "include_require_encrypted_put_bucket_policy" {
  description = "True to include bucket policy to required encrypted PUTs"
  type = bool
  default = true
}
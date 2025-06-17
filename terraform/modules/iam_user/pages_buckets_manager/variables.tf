variable "username" {
  type        = string
  description = "The username of the IAM user."
}

variable "bucket_prefix" {
  type        = string
  description = "The prefix of the buckets to which the user will be granted access."
}

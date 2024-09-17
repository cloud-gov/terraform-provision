variable "username" {
  type        = string
  description = "The username of the IAM user."
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket to which the user will be granted read-only access."
}

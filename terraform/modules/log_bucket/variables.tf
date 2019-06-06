variable "log_bucket_name" {}

variable "log_bucket_force_destroy" {
    default = false
}

variable "log_bucket_acl" {
    default = "private"
}

variable "aws_partition" {}

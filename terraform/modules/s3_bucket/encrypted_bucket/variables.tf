variable "bucket" {}

variable "acl" {
    default = "private"
}

variable "versioning" {
    default = "false"
}

variable "aws_partition" {}

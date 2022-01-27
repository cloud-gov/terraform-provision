variable "bucket" {
}

variable "acl" {
  default = "private"
}

variable "versioning" {
  default = "false"
}

variable "force_destroy" {
  default = "true"
}

variable "aws_partition" {
}

variable "expiration_days" {
  default = 0
}


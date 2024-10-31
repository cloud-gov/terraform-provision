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

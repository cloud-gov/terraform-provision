variable "origin" {
  type = object({
    lb_dns_name   = string
    lb_http_port  = number
    lb_https_port = number
  })
}

# variable "iam_certificate_id" {
#   type = string
# }

variable "aliases" {
  type    = set(string)
  default = []
}

variable "acl_arn" {
  type = string
}

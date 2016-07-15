variable "username" {}
variable "aws_partition" {}

variable "staging_private_bucket" {
  default: "cloud-gov-varz-staging" 
}

variable "prod_private_bucket" {
  default: "cloud-gov-varz" 
}

variable "bosh_releases_bucket" {
  default: "cloud-gov-bosh-release" 
}

variable "bosh_stemcells_bucket" {
  default: "cg-stemcell-images" 
}

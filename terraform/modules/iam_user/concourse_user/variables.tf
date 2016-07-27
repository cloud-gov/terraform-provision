variable "username" {}
variable "aws_partition" {}

variable "varz_staging_bucket" {
  default = "cloud-gov-varz-staging" 
}

variable "varz_bucket" {
  default= "cloud-gov-varz" 
}

variable "bosh_releases_bucket" {
  default = "cloud-gov-bosh-release" 
}

variable "bosh_stemcells_bucket" {
  default = "cg-stemcell-images" 
}

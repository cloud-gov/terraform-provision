variable "use_vpc_peering" {
  default = "0"
}

variable "tooling_state_bucket" {
  default = "tooling-hub"
}

variable "tooling_stack_name" {
  default = "hub"
}

variable "varz_bucket_name" {
    default = "cloud-gov-varz-hub"
}
variable "semver_bucket_name" {
    default = "cg-semver-hub"
}
variable "bosh_releases_bucket_name" {
    default = "cloud-gov-bosh-releases-hub"
}
variable "bosh_releases_blobstore_bucket_name" {
    default = "cloud-gov-release-blobstore-hub"
}

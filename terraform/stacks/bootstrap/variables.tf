variable "use_vpc_peering" {
  default = "0"
}

variable "tooling_state_bucket" {
  default = "terraform-state-hub"
}

variable "tooling_stack_name" {
  default = "hub"
}

# These are missing from tooling
variable "varz_bucket" {
    default = "cloud-gov-varz-hub"
}

variable "semver_bucket_name" {
    default = "cg-semver-hub"
}

variable "varz_bucket_stage" {
  default = "cloud-gov-varz-stage-hub"
}

terraform {
  # 1.2.0: this module uses resource and data source lifecycle precondition
  # blocks to require tgw_subnet_cidrs and remote_state_bucket only when
  # egress_traffic_through_inspection_vpc is true. Preconditions do not parse
  # before 1.2.
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 7.0.0"
    }
  }
}

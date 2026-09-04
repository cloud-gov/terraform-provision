terraform {
  backend "s3" {
  }
}

provider "aws" {
  use_fips_endpoint = true

  default_tags {
    tags = {
      deployment = "firewall-inspection-vpc"
    }
  }
}

module "nfw_inspection_vpc" {
  source                          = "../../modules/nfw_inspection_vpc"
  name_prefix                     = var.name_prefix
  tags                            = var.tags
  inspection_vpc_cidr             = var.inspection_vpc_cidr
  availability_zones              = var.availability_zones
  firewall_subnet_cidrs           = var.firewall_subnet_cidrs
  tgw_subnet_cidrs                = var.tgw_subnet_cidrs
  public_subnet_cidrs             = var.public_subnet_cidrs
  firewall_managed_rule_groups    = var.firewall_managed_rule_groups
  firewall_rule_groups_count_only = var.firewall_rule_groups_count_only
  delete_protection               = var.delete_protection
  logging_enabled                 = var.logging_enabled
  log_retention_days              = var.log_retention_days
}

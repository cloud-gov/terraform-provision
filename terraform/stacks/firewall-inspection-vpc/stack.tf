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
  source      = "../../modules/nfw_inspection_vpc"
  name_prefix = "nfw-inspection"
  tags = {
    owner  = "Steve"
    status = "development"
  }
  inspection_vpc_cidr   = "10.100.0.0/16"
  availability_zones    = ["us-gov-west-1a", "us-gov-west-1b"]
  firewall_subnet_cidrs = ["10.100.0.0/28", "10.100.0.16/28"]
  tgw_subnet_cidrs      = ["10.100.1.0/28", "10.100.1.16/28"]
  public_subnet_cidrs   = ["10.100.2.0/28", "10.100.2.16/28"]
  firewall_managed_rule_groups = [{
    resource_arn             = "arn:aws:network-firewall:us-gov-west-1:aws-managed:stateful-rulegroup/AttackInfrastructureStrictOrder"
    priority                 = 1
    override_action_to_count = true
  }]
  delete_protection  = false
  logging_enabled    = true
  log_retention_days = 1
}

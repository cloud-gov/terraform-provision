module "base" {
  source                             = "../base"
  stack_description                  = var.stack_description
  vpc_cidr                           = var.vpc_cidr
  az1                                = var.az1
  az2                                = var.az2
  aws_default_region                 = var.aws_default_region
  public_cidr_1                      = var.public_cidr_1
  public_cidr_2                      = var.public_cidr_2
  private_cidr_1                     = var.private_cidr_1
  private_cidr_2                     = var.private_cidr_2
  nat_gateway_instance_type          = var.nat_gateway_instance_type
  rds_private_cidr_1                 = var.rds_private_cidr_1
  rds_private_cidr_2                 = var.rds_private_cidr_2
  rds_private_cidr_3                 = var.rds_private_cidr_3
  rds_private_cidr_4                 = var.rds_private_cidr_4
  rds_instance_type                  = var.rds_instance_type
  rds_db_size                        = var.rds_db_size
  rds_db_name                        = var.rds_db_name
  rds_db_engine                      = var.rds_db_engine
  rds_db_engine_version              = var.rds_db_engine_version
  rds_parameter_group_family         = var.rds_parameter_group_family
  rds_allow_major_version_upgrade    = var.rds_allow_major_version_upgrade
  rds_apply_immediately              = var.rds_apply_immediately
  rds_username                       = var.rds_username
  rds_password                       = var.rds_password
  credhub_rds_password               = var.credhub_rds_password
  restricted_ingress_web_cidrs       = var.restricted_ingress_web_cidrs
  restricted_ingress_web_ipv6_cidrs  = var.restricted_ingress_web_ipv6_cidrs
  bosh_default_ssh_public_key        = var.bosh_default_ssh_public_key
  s3_gateway_policy_accounts         = var.s3_gateway_policy_accounts
  cidr_blocks                        = var.cidr_blocks
  credhub_rds_db_engine_version      = var.rds_db_engine_version_bosh_credhub
  credhub_rds_parameter_group_family = var.rds_parameter_group_family_bosh_credhub


  rds_security_groups = [
    module.base.bosh_security_group,
  ]
  rds_security_groups_count = 1

  rds_allowed_cidrs       = var.target_concourse_security_group_cidrs
  rds_allowed_cidrs_count = 1


  target_monitoring_security_group_cidrs = var.parent_monitoring_security_group_cidrs
  target_concourse_security_group_cidrs  = var.target_concourse_security_group_cidrs
}

module "vpc_peering" {
  # count as a cheap hack. Basically, if the parent and target vpcs are the same, skip this
  # we need to do this because otherwise we'll try to make duplicate entries in the route table
  count  = var.target_vpc_id == var.parent_vpc_id ? 0 : 1
  source = "../../vpc_peering"

  providers = {
    aws         = aws
    aws.tooling = aws.tooling
  }
  target_vpc_account_id  = var.target_account_id
  target_vpc_id          = var.target_vpc_id
  target_vpc_cidr        = var.target_vpc_cidr
  target_az1_route_table = var.target_az1_route_table
  target_az2_route_table = var.target_az2_route_table
  source_vpc_id          = module.base.vpc_id
  source_vpc_cidr        = module.base.vpc_cidr
  source_az1_route_table = module.base.private_route_table_az1
  source_az2_route_table = module.base.private_route_table_az2
}

module "vpc_peering_parentbosh" {
  source = "../../vpc_peering"

  providers = {
    aws         = aws
    aws.tooling = aws.parent
  }
  target_vpc_account_id  = var.parent_account_id
  target_vpc_id          = var.parent_vpc_id
  target_vpc_cidr        = var.parent_vpc_cidr
  target_az1_route_table = var.parent_az1_route_table
  target_az2_route_table = var.parent_az2_route_table
  source_vpc_id          = module.base.vpc_id
  source_vpc_cidr        = module.base.vpc_cidr
  source_az1_route_table = module.base.private_route_table_az1
  source_az2_route_table = module.base.private_route_table_az2
}

module "vpc_security_source_to_parent" {
  # and bosh -> monitoring stack
  providers = {
    aws = aws.parent
  }
  source = "../../vpc_peering_sg"

  target_bosh_security_group = var.parent_bosh_security_group
  source_vpc_cidr            = module.base.vpc_cidr
}

module "vpc_security_parent_to_source" {
  # toolingbosh -> envbosh
  source = "../../vpc_peering_sg"
  providers = {
    aws = aws
  }

  target_bosh_security_group = module.base.bosh_security_group
  source_vpc_cidr            = var.parent_vpc_cidr
}

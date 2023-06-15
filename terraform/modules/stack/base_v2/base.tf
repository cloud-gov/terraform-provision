module "vpc" {
  source = "../../bosh_vpc_v2"

  stack_description                 = var.stack_description
  vpc_cidr                          = var.vpc_cidr
  availability_zones                = var.availability_zones
  aws_default_region                = var.aws_default_region
  private_cidrs                     = var.private_cidrs
  public_cidrs                      = var.public_cidrs
  restricted_ingress_web_cidrs      = var.restricted_ingress_web_cidrs
  restricted_ingress_web_ipv6_cidrs = var.restricted_ingress_web_ipv6_cidrs
  nat_gateway_instance_type         = var.nat_gateway_instance_type
  monitoring_security_group_cidrs   = var.target_monitoring_security_group_cidrs
  concourse_security_group_cidrs    = var.target_concourse_security_group_cidrs
  bosh_default_ssh_public_key       = var.bosh_default_ssh_public_key
  s3_gateway_policy_accounts        = var.s3_gateway_policy_accounts
}

module "rds_network" {
  source = "../../rds_network"

  stack_description     = var.stack_description
  vpc_id                = module.vpc.vpc_id
  availability_zones    = var.availability_zones
  allowed_cidrs         = var.target_concourse_security_group_cidrs
  security_groups       = var.rds_security_groups
  security_groups_count = var.rds_security_groups_count
  rds_private_cidrrs    = var.rds_private_cidrs
  route_table_ids          = module.vpc.private_route_tables_ids
}

module "rds" {
  source = "../../rds"

  stack_description               = var.stack_description
  rds_instance_type               = var.rds_instance_type
  rds_db_size                     = var.rds_db_size
  rds_db_engine                   = var.rds_db_engine
  rds_db_engine_version           = var.rds_db_engine_version
  rds_db_name                     = var.rds_db_name
  rds_username                    = var.rds_username
  rds_password                    = var.rds_password
  rds_multi_az                    = var.rds_multi_az
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_subnet_group                = module.rds_network.rds_subnet_group
  rds_security_groups             = [module.rds_network.rds_postgres_security_group]
  rds_parameter_group_family      = var.rds_parameter_group_family
}

module "credhub_rds" {
  source = "../../rds"

  stack_description               = var.stack_description
  rds_db_name                     = var.credhub_rds_db_name
  rds_instance_type               = var.credhub_rds_instance_type
  rds_db_size                     = var.credhub_rds_db_size
  rds_db_storage_type             = var.credhub_rds_db_storage_type
  rds_db_engine_version           = var.credhub_rds_db_engine_version
  rds_username                    = var.credhub_rds_username
  rds_password                    = var.credhub_rds_password
  rds_subnet_group                = module.rds_network.rds_subnet_group
  rds_security_groups             = [module.rds_network.rds_postgres_security_group]
  rds_parameter_group_name        = var.rds_parameter_group_name
  rds_force_ssl                   = var.credhub_rds_force_ssl
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_parameter_group_family      = var.credhub_rds_parameter_group_family
}


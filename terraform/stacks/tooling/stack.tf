terraform {
  backend "s3" {
  }
}

provider "aws" {
  use_fips_endpoint = true
  default_tags {
    tags = {
      deployment = "tooling"
      stack      = "tooling"
    }
  }
}

data "aws_partition" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_availability_zones" "available" {
}

data "aws_region" "current" {
}

data "aws_iam_server_certificate" "wildcard_production" {
  name_prefix = var.wildcard_production_certificate_name_prefix
  latest      = true
}

data "aws_iam_server_certificate" "wildcard_staging" {
  name_prefix = var.wildcard_staging_certificate_name_prefix
  latest      = true
}

data "aws_iam_server_certificate" "wildcard_development" {
  name_prefix = var.wildcard_development_certificate_name_prefix
  latest      = true
}

resource "aws_lb" "main" {
  name            = "${var.stack_description}-main"
  subnets         = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  security_groups = [module.stack.restricted_web_traffic_security_group]
  ip_address_type = "dualstack"
  idle_timeout    = 3600
  access_logs {
    bucket  = var.log_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
  enable_deletion_protection = true
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.aws_lb_listener_ssl_policy
  certificate_arn   = data.aws_iam_server_certificate.wildcard_production.arn

  default_action {
    target_group_arn = aws_lb_target_group.dummy.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "dummy" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.stack.vpc_id
}

resource "aws_lb_listener_certificate" "main-staging" {
  listener_arn    = aws_lb_listener.main.arn
  certificate_arn = data.aws_iam_server_certificate.wildcard_staging.arn
}

resource "aws_lb_listener_certificate" "main-development" {
  listener_arn    = aws_lb_listener.main.arn
  certificate_arn = data.aws_iam_server_certificate.wildcard_development.arn
}

module "stack" {
  source = "../../modules/stack/base"

  stack_description                      = var.stack_description
  vpc_cidr                               = var.vpc_cidr
  az1                                    = data.aws_availability_zones.available.names[0]
  az2                                    = data.aws_availability_zones.available.names[1]
  aws_default_region                     = var.aws_default_region
  public_cidr_1                          = cidrsubnet(var.vpc_cidr, 8, 100)
  public_cidr_2                          = cidrsubnet(var.vpc_cidr, 8, 101)
  private_cidr_1                         = cidrsubnet(var.vpc_cidr, 8, 1) # This is used by nessus, opsuaa and postfix
  private_cidr_2                         = cidrsubnet(var.vpc_cidr, 8, 2)
  restricted_ingress_web_cidrs           = var.restricted_ingress_web_cidrs
  restricted_ingress_web_ipv6_cidrs      = var.restricted_ingress_web_ipv6_cidrs
  rds_private_cidr_1                     = cidrsubnet(var.vpc_cidr, 8, 20)
  rds_private_cidr_2                     = cidrsubnet(var.vpc_cidr, 8, 21)
  rds_private_cidr_3                     = cidrsubnet(var.vpc_cidr, 7, 11) # This will give 22-23
  rds_private_cidr_4                     = cidrsubnet(var.vpc_cidr, 7, 12) # This will give 24-25
  rds_password                           = var.rds_password
  credhub_rds_password                   = var.credhub_rds_password
  rds_multi_az                           = var.rds_multi_az
  rds_security_groups                    = [module.stack.bosh_security_group]
  rds_security_groups_count              = "1"
  rds_db_engine_version                  = var.rds_db_engine_version_bosh
  rds_parameter_group_family             = var.rds_parameter_group_family_bosh
  rds_force_ssl                          = var.rds_force_ssl_bosh
  rds_allow_major_version_upgrade        = var.rds_allow_major_version_upgrade
  rds_apply_immediately                  = var.rds_apply_immediately
  bosh_default_ssh_public_key            = var.bosh_default_ssh_public_key
  target_concourse_security_group_cidrs  = [cidrsubnet(var.vpc_cidr, 8, 30), cidrsubnet(var.vpc_cidr, 8, 31), cidrsubnet(var.vpc_cidr, 8, 38), cidrsubnet(var.vpc_cidr, 8, 1)]
  target_monitoring_security_group_cidrs = [cidrsubnet(var.vpc_cidr, 8, 32)]
  s3_gateway_policy_accounts             = var.s3_gateway_policy_accounts
  credhub_rds_db_engine_version          = var.rds_db_engine_version_bosh_credhub
  credhub_rds_parameter_group_family     = var.rds_parameter_group_family_bosh_credhub

  rds_add_pgaudit_to_shared_preload_libraries_bosh_credhub = var.rds_add_pgaudit_to_shared_preload_libraries_bosh_credhub
  rds_add_pgaudit_log_parameter_bosh_credhub               = var.rds_add_pgaudit_log_parameter_bosh_credhub
  rds_shared_preload_libraries_bosh_credhub                = var.rds_shared_preload_libraries_bosh_credhub
  rds_pgaudit_log_values_bosh_credhub                      = var.rds_pgaudit_log_values_bosh_credhub
  rds_add_log_replication_commands_bosh_credhub            = var.rds_add_log_replication_commands_bosh_credhub


  rds_add_pgaudit_to_shared_preload_libraries_bosh = var.rds_add_pgaudit_to_shared_preload_libraries_bosh
  rds_add_pgaudit_log_parameter_bosh               = var.rds_add_pgaudit_log_parameter_bosh
  rds_shared_preload_libraries_bosh                = var.rds_shared_preload_libraries_bosh
  rds_pgaudit_log_values_bosh                      = var.rds_pgaudit_log_values_bosh
  rds_add_log_replication_commands_bosh            = var.rds_add_log_replication_commands_bosh

}

module "concourse_production" {
  source                          = "../../modules/concourse"
  stack_description               = var.stack_description
  vpc_id                          = module.stack.vpc_id
  concourse_cidr                  = cidrsubnet(var.vpc_cidr, 8, 30)
  concourse_cidr_az2              = cidrsubnet(var.vpc_cidr, 8, 60)
  concourse_az                    = data.aws_availability_zones.available.names[0]
  concourse_az2                   = data.aws_availability_zones.available.names[1]
  suffix                          = data.aws_availability_zones.available.names[0]
  route_table_id                  = module.stack.private_route_table_az1
  route_table_id_az2              = module.stack.private_route_table_az2
  rds_password                    = var.concourse_prod_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-concourse-production"
  rds_parameter_group_family      = var.rds_parameter_group_family_concourse_production
  rds_db_engine_version           = var.rds_db_engine_version_concourse_production
  rds_apply_immediately           = var.rds_apply_immediately
  rds_force_ssl                   = var.rds_force_ssl_concourse_production
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  performance_insights_enabled    = "true"
  rds_instance_type               = "db.m5.4xlarge"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-atc-tooling-production"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.concourse_production_hosts

  rds_add_pgaudit_to_shared_preload_libraries = var.rds_add_pgaudit_to_shared_preload_libraries_concourse_production
  rds_add_pgaudit_log_parameter               = var.rds_add_pgaudit_log_parameter_concourse_production
  rds_shared_preload_libraries                = var.rds_shared_preload_libraries_concourse_production
  rds_pgaudit_log_values                      = var.rds_pgaudit_log_values_concourse_production
  rds_add_log_replication_commands            = var.rds_add_log_replication_commands_concourse_production
}

module "concourse_staging" {
  source                          = "../../modules/concourse"
  stack_description               = var.stack_description
  vpc_id                          = module.stack.vpc_id
  concourse_cidr                  = cidrsubnet(var.vpc_cidr, 8, 31)
  concourse_cidr_az2              = cidrsubnet(var.vpc_cidr, 8, 61)
  concourse_az                    = data.aws_availability_zones.available.names[1] # Yes, these are backwards on purpose, this is the original
  concourse_az2                   = data.aws_availability_zones.available.names[0] # Yes, these are backwards on purpose, this is the new az
  suffix                          = data.aws_availability_zones.available.names[1]
  route_table_id                  = module.stack.private_route_table_az2 # Yes, these are backwards on purpose, this is the original
  route_table_id_az2              = module.stack.private_route_table_az1 # Yes, these are backwards on purpose, this is the new az
  rds_password                    = var.concourse_staging_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-concourse-staging"
  rds_parameter_group_family      = var.rds_parameter_group_family_concourse_staging
  rds_db_engine_version           = var.rds_db_engine_version_concourse_staging
  rds_apply_immediately           = var.rds_apply_immediately
  rds_force_ssl                   = var.rds_force_ssl_concourse_staging
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-atc-tooling-staging"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.concourse_staging_hosts

  rds_add_pgaudit_to_shared_preload_libraries = var.rds_add_pgaudit_to_shared_preload_libraries_concourse_staging
  rds_add_pgaudit_log_parameter               = var.rds_add_pgaudit_log_parameter_concourse_staging
  rds_shared_preload_libraries                = var.rds_shared_preload_libraries_concourse_staging
  rds_pgaudit_log_values                      = var.rds_pgaudit_log_values_concourse_staging
  rds_add_log_replication_commands            = var.rds_add_log_replication_commands_concourse_production
}

module "credhub_production" {
  source                          = "../../modules/credhub"
  stack_description               = var.stack_description
  vpc_id                          = module.stack.vpc_id
  credhub_cidr_az1                = cidrsubnet(var.vpc_cidr, 8, 35)
  credhub_cidr_az2                = cidrsubnet(var.vpc_cidr, 8, 37)
  credhub_az1                     = data.aws_availability_zones.available.names[0]
  credhub_az2                     = data.aws_availability_zones.available.names[1]
  route_table_id_az1              = module.stack.private_route_table_az1
  route_table_id_az2              = module.stack.private_route_table_az2
  rds_password                    = var.credhub_prod_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-credhub-production"
  rds_parameter_group_family      = var.rds_parameter_group_family_credhub_production
  rds_db_engine_version           = var.rds_db_engine_version_credhub_production
  rds_apply_immediately           = var.rds_apply_immediately
  rds_force_ssl                   = var.rds_force_ssl_credhub_production
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-credhub-tooling-production"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.credhub_production_hosts

  rds_add_pgaudit_to_shared_preload_libraries = var.rds_add_pgaudit_to_shared_preload_libraries_credhub_production
  rds_add_pgaudit_log_parameter               = var.rds_add_pgaudit_log_parameter_credhub_production
  rds_shared_preload_libraries                = var.rds_shared_preload_libraries_credhub_production
  rds_pgaudit_log_values                      = var.rds_pgaudit_log_values_credhub_production
  rds_add_log_replication_commands            = var.rds_add_log_replication_commands_credhub_production
}

module "credhub_staging" {
  source                          = "../../modules/credhub"
  stack_description               = "staging"
  vpc_id                          = module.stack.vpc_id
  credhub_cidr_az1                = cidrsubnet(var.vpc_cidr, 8, 34)
  credhub_cidr_az2                = cidrsubnet(var.vpc_cidr, 8, 36)
  credhub_az1                     = data.aws_availability_zones.available.names[0]
  credhub_az2                     = data.aws_availability_zones.available.names[1]
  route_table_id_az1              = module.stack.private_route_table_az1
  route_table_id_az2              = module.stack.private_route_table_az2
  rds_password                    = var.credhub_staging_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-credhub-staging"
  rds_parameter_group_family      = var.rds_parameter_group_family_credhub_staging
  rds_db_engine_version           = var.rds_db_engine_version_credhub_staging
  rds_apply_immediately           = var.rds_apply_immediately
  rds_force_ssl                   = var.rds_force_ssl_credhub_staging
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-credhub-tooling-staging"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.credhub_staging_hosts

  rds_add_pgaudit_to_shared_preload_libraries = var.rds_add_pgaudit_to_shared_preload_libraries_credhub_staging
  rds_add_pgaudit_log_parameter               = var.rds_add_pgaudit_log_parameter_credhub_staging
  rds_shared_preload_libraries                = var.rds_shared_preload_libraries_credhub_staging
  rds_pgaudit_log_values                      = var.rds_pgaudit_log_values_credhub_staging
  rds_add_log_replication_commands            = var.rds_add_log_replication_commands_credhub_staging

}

module "defectdojo_development" {
  source                          = "../../modules/defect_dojo"
  stack_description               = "development"
  vpc_id                          = module.stack.vpc_id
  defectdojo_cidr_az1             = cidrsubnet(var.vpc_cidr, 8, 50)
  defectdojo_cidr_az2             = cidrsubnet(var.vpc_cidr, 8, 51)
  defectdojo_az1                  = data.aws_availability_zones.available.names[0]
  defectdojo_az2                  = data.aws_availability_zones.available.names[1]
  route_table_id_az1              = module.stack.private_route_table_az1
  route_table_id_az2              = module.stack.private_route_table_az2
  rds_password                    = var.defectdojo_development_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-defectdojo-development"
  rds_parameter_group_family      = var.rds_parameter_group_family_defectdojo_development
  rds_db_engine_version           = var.rds_db_engine_version_defectdojo_development
  rds_force_ssl                   = var.rds_force_ssl_defectdojo_development
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.t3.medium"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-defectdojo-tooling-development"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.defectdojo_development_hosts

  rds_add_pgaudit_to_shared_preload_libraries = var.rds_add_pgaudit_to_shared_preload_libraries_defectdojo_development
  rds_add_pgaudit_log_parameter               = var.rds_add_pgaudit_log_parameter_defectdojo_development
  rds_shared_preload_libraries                = var.rds_shared_preload_libraries_defectdojo_development
  rds_pgaudit_log_values                      = var.rds_pgaudit_log_values_defectdojo_development
  rds_add_log_replication_commands            = var.rds_add_log_replication_commands_defectdojo_development

}

module "defectdojo_staging" {
  source                          = "../../modules/defect_dojo"
  stack_description               = var.stack_description
  vpc_id                          = module.stack.vpc_id
  defectdojo_cidr_az1             = cidrsubnet(var.vpc_cidr, 8, 48)
  defectdojo_cidr_az2             = cidrsubnet(var.vpc_cidr, 8, 49)
  defectdojo_az1                  = data.aws_availability_zones.available.names[0]
  defectdojo_az2                  = data.aws_availability_zones.available.names[1]
  route_table_id_az1              = module.stack.private_route_table_az1
  route_table_id_az2              = module.stack.private_route_table_az2
  rds_password                    = var.defectdojo_staging_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-defectdojo-staging"
  rds_parameter_group_family      = var.rds_parameter_group_family_defectdojo_staging
  rds_db_engine_version           = var.rds_db_engine_version_defectdojo_staging
  rds_force_ssl                   = var.rds_force_ssl_defectdojo_staging
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-defectdojo-tooling-staging"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.defectdojo_staging_hosts

  rds_add_pgaudit_to_shared_preload_libraries = var.rds_add_pgaudit_to_shared_preload_libraries_defectdojo_staging
  rds_add_pgaudit_log_parameter               = var.rds_add_pgaudit_log_parameter_defectdojo_staging
  rds_shared_preload_libraries                = var.rds_shared_preload_libraries_defectdojo_staging
  rds_pgaudit_log_values                      = var.rds_pgaudit_log_values_defectdojo_staging
  rds_add_log_replication_commands            = var.rds_add_log_replication_commands_defectdojo_staging
}

module "defectdojo_production" {
  source                          = "../../modules/defect_dojo"
  stack_description               = "production"
  vpc_id                          = module.stack.vpc_id
  defectdojo_cidr_az1             = cidrsubnet(var.vpc_cidr, 8, 52)
  defectdojo_cidr_az2             = cidrsubnet(var.vpc_cidr, 8, 53)
  defectdojo_az1                  = data.aws_availability_zones.available.names[0]
  defectdojo_az2                  = data.aws_availability_zones.available.names[1]
  route_table_id_az1              = module.stack.private_route_table_az1
  route_table_id_az2              = module.stack.private_route_table_az2
  rds_password                    = var.defectdojo_production_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-defectdojo-production"
  rds_parameter_group_family      = var.rds_parameter_group_family_defectdojo_production
  rds_db_engine_version           = var.rds_db_engine_version_defectdojo_production
  rds_force_ssl                   = var.rds_force_ssl_defectdojo_staging
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-defectdojo-tooling-production"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.defectdojo_production_hosts

  rds_add_pgaudit_to_shared_preload_libraries = var.rds_add_pgaudit_to_shared_preload_libraries_defectdojo_production
  rds_add_pgaudit_log_parameter               = var.rds_add_pgaudit_log_parameter_defectdojo_production
  rds_shared_preload_libraries                = var.rds_shared_preload_libraries_defectdojo_production
  rds_pgaudit_log_values                      = var.rds_pgaudit_log_values_defectdojo_production
  rds_add_log_replication_commands            = var.rds_add_log_replication_commands_defectdojo_production
}

module "monitoring_production" {
  source                      = "../../modules/monitoring"
  stack_description           = "production"
  vpc_id                      = module.stack.vpc_id
  vpc_cidr                    = var.vpc_cidr
  monitoring_cidr             = cidrsubnet(var.vpc_cidr, 8, 32)
  monitoring_az               = data.aws_availability_zones.available.names[0]
  route_table_id              = module.stack.private_route_table_az1
  listener_arn                = aws_lb_listener.main.arn
  hosts                       = var.monitoring_production_hosts
  doomsday_oidc_client        = var.doomsday_oidc_client
  doomsday_oidc_client_secret = var.doomsday_oidc_client_secret
  opslogin_hostname           = var.opslogin_hostname
}

module "monitoring_staging" {
  source                      = "../../modules/monitoring"
  stack_description           = "staging"
  vpc_id                      = module.stack.vpc_id
  vpc_cidr                    = var.vpc_cidr
  monitoring_cidr             = cidrsubnet(var.vpc_cidr, 8, 33)
  monitoring_az               = data.aws_availability_zones.available.names[1]
  route_table_id              = module.stack.private_route_table_az2
  listener_arn                = aws_lb_listener.main.arn
  hosts                       = var.monitoring_staging_hosts
  doomsday_oidc_client        = var.doomsday_oidc_client
  doomsday_oidc_client_secret = var.doomsday_oidc_client_secret
  opslogin_hostname           = var.opslogin_hostname
}

resource "aws_eip" "production_dns_eip" {
  domain = "vpc"

  count = var.dns_eip_count_production

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "staging_dns_eip" {
  domain = "vpc"

  count = var.dns_eip_count_staging

  lifecycle {
    prevent_destroy = true
  }
}

module "dns" {
  source            = "../../modules/dns"
  stack_description = var.stack_description
  vpc_id            = module.stack.vpc_id
}

module "smtp" {
  source              = "../../modules/smtp"
  stack_description   = var.stack_description
  vpc_id              = module.stack.vpc_id
  ingress_cidr_blocks = var.smtp_ingress_cidr_blocks
}

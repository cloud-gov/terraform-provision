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
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
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
  rds_db_engine_version                  = var.rds_db_engine_version
  rds_parameter_group_family             = var.rds_parameter_group_family
  rds_allow_major_version_upgrade        = var.rds_allow_major_version_upgrade
  rds_apply_immediately                  = var.rds_apply_immediately
  bosh_default_ssh_public_key            = var.bosh_default_ssh_public_key
  target_concourse_security_group_cidrs  = [cidrsubnet(var.vpc_cidr, 8, 30), cidrsubnet(var.vpc_cidr, 8, 31), cidrsubnet(var.vpc_cidr, 8, 38), cidrsubnet(var.vpc_cidr, 8, 1)]
  target_monitoring_security_group_cidrs = [cidrsubnet(var.vpc_cidr, 8, 32)]
  s3_gateway_policy_accounts             = var.s3_gateway_policy_accounts
}

module "concourse_production" {
  source                          = "../../modules/concourse"
  stack_description               = var.stack_description
  vpc_id                          = module.stack.vpc_id
  concourse_cidr                  = cidrsubnet(var.vpc_cidr, 8, 30)
  concourse_az                    = data.aws_availability_zones.available.names[0]
  suffix                          = data.aws_availability_zones.available.names[0]
  route_table_id                  = module.stack.private_route_table_az1
  rds_password                    = var.concourse_prod_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-concourse-production"
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.xlarge"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-atc-tooling-production"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.concourse_production_hosts
}

module "concourse_production_pages" {
  source                          = "../../modules/concourse"
  stack_description               = var.stack_description
  vpc_id                          = module.stack.vpc_id
  concourse_cidr                  = cidrsubnet(var.vpc_cidr, 8, 38)
  concourse_az                    = data.aws_availability_zones.available.names[1]
  suffix                          = "pages"
  route_table_id                  = module.stack.private_route_table_az1
  rds_password                    = var.concourse_prod_pages_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-concourse-production-pages"
  rds_parameter_group_family      = "postgres15"
  rds_db_engine_version           = "15.5"
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-atc-tooling-staging"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.concourse_production_pages_hosts
}

module "concourse_staging" {
  source                          = "../../modules/concourse"
  stack_description               = var.stack_description
  vpc_id                          = module.stack.vpc_id
  concourse_cidr                  = cidrsubnet(var.vpc_cidr, 8, 31)
  concourse_az                    = data.aws_availability_zones.available.names[1]
  suffix                          = data.aws_availability_zones.available.names[1]
  route_table_id                  = module.stack.private_route_table_az2
  rds_password                    = var.concourse_staging_rds_password
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-concourse-staging"
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-atc-tooling-staging"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.concourse_staging_hosts
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
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-credhub-tooling-production"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.credhub_production_hosts
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
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m5.large"
  rds_db_size                     = 400
  rds_db_storage_type             = "gp3"
  rds_db_iops                     = 12000
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-credhub-tooling-staging"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.credhub_staging_hosts
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
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
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
}

module "monitoring_production" {
  source             = "../../modules/monitoring"
  stack_description  = "production"
  vpc_id             = module.stack.vpc_id
  vpc_cidr           = var.vpc_cidr
  monitoring_cidr    = cidrsubnet(var.vpc_cidr, 8, 32)
  monitoring_az      = data.aws_availability_zones.available.names[0]
  route_table_id     = module.stack.private_route_table_az1
  listener_arn       = aws_lb_listener.main.arn
  hosts              = var.monitoring_production_hosts
  oidc_client        = var.oidc_client
  oidc_client_secret = var.oidc_client_secret
  opslogin_hostname  = var.opslogin_hostname
}

module "monitoring_staging" {
  source             = "../../modules/monitoring"
  stack_description  = "staging"
  vpc_id             = module.stack.vpc_id
  vpc_cidr           = var.vpc_cidr
  monitoring_cidr    = cidrsubnet(var.vpc_cidr, 8, 33)
  monitoring_az      = data.aws_availability_zones.available.names[1]
  route_table_id     = module.stack.private_route_table_az2
  listener_arn       = aws_lb_listener.main.arn
  hosts              = var.monitoring_staging_hosts
  oidc_client        = var.oidc_client
  oidc_client_secret = var.oidc_client_secret
  opslogin_hostname  = var.opslogin_hostname
}

resource "aws_eip" "production_dns_eip" {
  vpc = true

  count = var.dns_eip_count_production

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "staging_dns_eip" {
  vpc = true

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

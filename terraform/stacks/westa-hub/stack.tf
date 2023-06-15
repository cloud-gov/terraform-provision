terraform {
  backend "s3" {
  }
}

provider "aws" {
  use_fips_endpoint = true
  default_tags {
    tags = {
      deployment = "tooling"
      stack      = "westa-hub"
      region     = "westa"
      environment = "hub"
      provisioner = "terraform"
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
    bucket  = module.log_bucket.elb_bucket_name
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
  source = "../../modules/stack/base_v2"

  stack_description                      = var.stack_description
  vpc_cidr                               = var.vpc_cidr
  availability_zones                     = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  aws_default_region                     = var.aws_default_region
  public_cidrs                           = [cidrsubnet(var.vpc_cidr, 8, 100), cidrsubnet(var.vpc_cidr, 8, 101), cidrsubnet(var.vpc_cidr, 8, 102)]
  private_cidrs                          = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2), cidrsubnet(var.vpc_cidr, 8, 3)]
  restricted_ingress_web_cidrs           = var.restricted_ingress_web_cidrs
  restricted_ingress_web_ipv6_cidrs      = var.restricted_ingress_web_ipv6_cidrs
  rds_private_cidrs                      = [cidrsubnet(var.vpc_cidr, 8, 20), cidrsubnet(var.vpc_cidr, 8, 21), cidrsubnet(var.vpc_cidr, 8, 22)]
  rds_password                           = random_string.rds_password.result
  credhub_rds_password                   = random_string.credhub_rds_password.result
  rds_multi_az                           = var.rds_multi_az
  rds_security_groups                    = [module.stack.bosh_security_group]
  rds_security_groups_count              = "1"
  rds_db_engine_version                  = var.rds_db_engine_version
  rds_parameter_group_family             = var.rds_parameter_group_family
  rds_allow_major_version_upgrade        = var.rds_allow_major_version_upgrade
  rds_apply_immediately                  = var.rds_apply_immediately
  bosh_default_ssh_public_key            = tls_private_key.bosh_key.public_key_openssh
  target_concourse_security_group_cidrs  = [cidrsubnet(var.vpc_cidr, 8, 30), cidrsubnet(var.vpc_cidr, 8, 31), cidrsubnet(var.vpc_cidr, 8, 32), cidrsubnet(var.vpc_cidr, 8, 33), cidrsubnet(var.vpc_cidr, 8, 34), cidrsubnet(var.vpc_cidr, 8, 35), cidrsubnet(var.vpc_cidr, 8, 1)]
  target_monitoring_security_group_cidrs = [cidrsubnet(var.vpc_cidr, 8, 42), cidrsubnet(var.vpc_cidr, 8, 43), cidrsubnet(var.vpc_cidr, 8, 44)] //Why only Prod?
  s3_gateway_policy_accounts             = var.s3_gateway_policy_accounts
}

module "concourse_production" {
  source                          = "../../modules/concourse"
  stack_description               = "production"  # var.stack_description is too long, max 32 length total
  vpc_id                          = module.stack.vpc_id
  concourse_cidrs                 = [cidrsubnet(var.vpc_cidr, 8, 30),cidrsubnet(var.vpc_cidr, 8, 31),cidrsubnet(var.vpc_cidr, 8, 30)]
  concourse_availability_zones    = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1],data.aws_availability_zones.available.names[2]]
  route_table_ids                  = module.stack.private_route_table_ids
  rds_password                    = random_string.concourse_prod_rds_password.result
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-concourse-production"
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = "db.m4.xlarge"
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-atc-tooling-production"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.concourse_production_hosts
}

module "concourse_staging" {
  source                          = "../../modules/concourse"
  stack_description               = "staging"  # var.stack_description is too long, max 32 length total
  vpc_id                          = module.stack.vpc_id
  concourse_cidrs                 = [cidrsubnet(var.vpc_cidr, 8, 33),cidrsubnet(var.vpc_cidr, 8, 34),cidrsubnet(var.vpc_cidr, 8, 35)]
  concourse_availability_zones    = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1],data.aws_availability_zones.available.names[2]]
  route_table_ids                 = module.stack.private_route_table_ids
  rds_password                    = random_string.concourse_staging_rds_password.result
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-concourse-staging"
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = var.concourse_staging_rds_instance_type
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-atc-tooling-staging"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.concourse_staging_hosts
}

module "credhub_production" {
  source                          = "../../modules/credhub"
  stack_description               = "production"
  vpc_id                          = module.stack.vpc_id
  credhub_cidrs                   = [cidrsubnet(var.vpc_cidr, 8, 36), cidrsubnet(var.vpc_cidr, 8, 37), cidrsubnet(var.vpc_cidr, 8, 38)]
  credhub_availability_zones      = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1],data.aws_availability_zones.available.names[2]]
  route_table_ids                 = module.stack.private_route_table_ids
  rds_password                    = random_string.credhub_prod_rds_password.result
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-credhub-production"
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = var.credhub_production_rds_instance_type
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-credhub-tooling-production"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.credhub_production_hosts
}

module "credhub_staging" {
  source                          = "../../modules/credhub"
  stack_description               = "staging"
  vpc_id                          = module.stack.vpc_id
  credhub_cidrs                   = [cidrsubnet(var.vpc_cidr, 8, 39), cidrsubnet(var.vpc_cidr, 8, 40), cidrsubnet(var.vpc_cidr, 8, 41)]
  credhub_availability_zones      = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1],data.aws_availability_zones.available.names[2]]
  route_table_ids                 = module.stack.private_route_table_ids
  rds_password                    = random_string.credhub_staging_rds_password.result
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_parameter_group_name        = "tooling-credhub-staging"
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_db_engine_version           = var.rds_db_engine_version
  rds_apply_immediately           = var.rds_apply_immediately
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_instance_type               = var.credhub_staging_rds_instance_type
  rds_multi_az                    = var.rds_multi_az
  rds_final_snapshot_identifier   = "final-snapshot-credhub-tooling-staging"
  listener_arn                    = aws_lb_listener.main.arn
  hosts                           = var.credhub_staging_hosts
}

module "monitoring_production" {
  source                        = "../../modules/monitoring"
  stack_description             = "production"
  vpc_id                        = module.stack.vpc_id
  vpc_cidr                      = var.vpc_cidr
  monitoring_cidrs              = [cidrsubnet(var.vpc_cidr, 8, 42),cidrsubnet(var.vpc_cidr, 8, 43),cidrsubnet(var.vpc_cidr, 8, 44)]
  monitoring_availability_zones = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1],data.aws_availability_zones.available.names[2]]
  route_table_ids               = module.stack.private_route_table_ids
  listener_arn                  = aws_lb_listener.main.arn
  hosts                         = var.monitoring_production_hosts
  oidc_client                   = var.oidc_client
  oidc_client_secret            = random_string.oidc_client_secret.result
  opslogin_hostname             = var.opslogin_hostname
}

module "monitoring_staging" {
  source             = "../../modules/monitoring"
  stack_description  = "staging"
  vpc_id             = module.stack.vpc_id
  vpc_cidr           = var.vpc_cidr
  monitoring_cidrs              = [cidrsubnet(var.vpc_cidr, 8, 45),cidrsubnet(var.vpc_cidr, 8, 46),cidrsubnet(var.vpc_cidr, 8, 47)]
  monitoring_availability_zones = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1],data.aws_availability_zones.available.names[2]]
  route_table_ids               = module.stack.private_route_table_ids
  listener_arn       = aws_lb_listener.main.arn
  hosts              = var.monitoring_staging_hosts
  oidc_client        = var.oidc_client
  oidc_client_secret = random_string.oidc_client_secret.result
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


terraform {
  backend "s3" {
  }
}

provider "aws" {
}

data "terraform_remote_state" "target_vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = "${var.target_stack_name}/terraform.tfstate"
  }
}

data "aws_partition" "current" {
}

data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "aws_iam_server_certificate" "wildcard" {
  name_prefix = var.wildcard_certificate_name_prefix
  latest      = true
}

data "aws_iam_server_certificate" "wildcard_apps" {
  name_prefix = var.wildcard_apps_certificate_name_prefix
  latest      = true
}

data "aws_iam_server_certificate" "wildcard_pages_staging" {
  name_prefix = var.wildcard_pages_staging_certificate_name_prefix
  latest      = true
}

data "aws_iam_server_certificate" "wildcard_sites_pages_staging" {
  name_prefix = var.wildcard_sites_pages_staging_certificate_name_prefix
  latest      = true
}

resource "aws_lb" "main" {
  name    = "${var.stack_description}-main"
  subnets = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]
  security_groups = [
    var.force_restricted_network == "no" ? module.stack.web_traffic_security_group : module.stack.restricted_web_traffic_security_group,
  ]

  ip_address_type = "dualstack"
  idle_timeout    = 3600

  access_logs {
    bucket  = var.log_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_iam_server_certificate.wildcard.arn

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

module "stack" {
  source = "../../modules/stack/spoke"

  stack_description                 = var.stack_description
  aws_partition                     = data.aws_partition.current.partition
  vpc_cidr                          = var.vpc_cidr
  aws_default_region                = var.aws_default_region
  rds_db_size                       = var.rds_db_size
  rds_apply_immediately             = var.rds_apply_immediately
  rds_allow_major_version_upgrade   = var.rds_allow_major_version_upgrade
  public_cidr_1                     = cidrsubnet(var.vpc_cidr, 8, 100)
  public_cidr_2                     = cidrsubnet(var.vpc_cidr, 8, 101)
  private_cidr_1                    = cidrsubnet(var.vpc_cidr, 8, 1)
  private_cidr_2                    = cidrsubnet(var.vpc_cidr, 8, 2)
  rds_private_cidr_1                = cidrsubnet(var.vpc_cidr, 8, 20)
  rds_private_cidr_2                = cidrsubnet(var.vpc_cidr, 8, 21)
  restricted_ingress_web_cidrs      = var.restricted_ingress_web_cidrs
  restricted_ingress_web_ipv6_cidrs = var.restricted_ingress_web_ipv6_cidrs
  rds_password                      = var.rds_password
  credhub_rds_password              = var.credhub_rds_password
  account_id                        = data.aws_caller_identity.current.account_id

  target_vpc_id              = data.terraform_remote_state.target_vpc.outputs.vpc_id
  target_vpc_cidr            = data.terraform_remote_state.target_vpc.outputs.vpc_cidr
  target_bosh_security_group = data.terraform_remote_state.target_vpc.outputs.bosh_security_group
  target_az1_route_table     = data.terraform_remote_state.target_vpc.outputs.private_route_table_az1
  target_az2_route_table     = data.terraform_remote_state.target_vpc.outputs.private_route_table_az2

  target_monitoring_security_groups = [
    data.terraform_remote_state.target_vpc.outputs.monitoring_security_groups[var.stack_description],
  ]

  target_concourse_security_groups = [
    data.terraform_remote_state.target_vpc.outputs.production_concourse_security_group,
    data.terraform_remote_state.target_vpc.outputs.staging_concourse_security_group,
  ]

  target_credhub_security_groups = [
    data.terraform_remote_state.target_vpc.outputs.production_credhub_security_group,
    data.terraform_remote_state.target_vpc.outputs.staging_credhub_security_group,
  ]
}

module "cf" {
  source = "../../modules/cloudfoundry"

  stack_description           = var.stack_description
  aws_partition               = data.aws_partition.current.partition
  elb_main_cert_id            = data.aws_iam_server_certificate.wildcard.arn
  elb_apps_cert_id            = data.aws_iam_server_certificate.wildcard_apps.arn
  pages_staging_cert_id       = data.aws_iam_server_certificate.wildcard_pages_staging.arn
  sites_pages_staging_cert_id = data.aws_iam_server_certificate.wildcard_sites_pages_staging.arn
  elb_subnets                 = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]

  elb_security_groups = [
    var.force_restricted_network == "no" ? module.stack.web_traffic_security_group : module.stack.restricted_web_traffic_security_group,
  ]

  rds_password        = var.cf_rds_password
  rds_subnet_group    = module.stack.rds_subnet_group
  rds_security_groups = [module.stack.rds_postgres_security_group]
  stack_prefix        = var.stack_prefix

  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_apply_immediately           = var.rds_apply_immediately

  vpc_id                  = module.stack.vpc_id
  private_route_table_az1 = module.stack.private_route_table_az1
  private_route_table_az2 = module.stack.private_route_table_az2

  services_cidr_1       = cidrsubnet(var.vpc_cidr, 8, 30)
  services_cidr_2       = cidrsubnet(var.vpc_cidr, 8, 31)
  bucket_prefix         = var.bucket_prefix
  log_bucket_name       = var.log_bucket_name
}

resource "aws_wafv2_web_acl_association" "main_waf_core" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = module.cf.cf_uaa_waf_core_arn
}

module "diego" {
  source = "../../modules/diego"

  stack_description = var.stack_description
  elb_subnets       = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]

  vpc_id = module.stack.vpc_id

  # Workaround for https://github.com/hashicorp/terraform/issues/12453
  ingress_cidrs = split(
    ",",
    var.force_restricted_network == "no" ? "0.0.0.0/0" : join(",", var.restricted_ingress_web_cidrs),
  )

  log_bucket_name = var.log_bucket_name
}


module "logsearch" {
  source = "../../modules/logsearch"

  stack_description   = var.stack_description
  vpc_id              = module.stack.vpc_id
  private_elb_subnets = [module.cf.services_subnet_az1, module.cf.services_subnet_az2]
  bosh_security_group = module.stack.bosh_security_group
  listener_arn        = aws_lb_listener.main.arn
  hosts               = var.platform_kibana_hosts
  log_bucket_name     = var.log_bucket_name
}

module "shibboleth" {
  source = "../../modules/shibboleth"

  stack_description = var.stack_description
  vpc_id            = module.stack.vpc_id
  listener_arn      = aws_lb_listener.main.arn
  hosts             = var.shibboleth_hosts
}

module "admin" {
  source = "../../modules/admin"

  stack_description = var.stack_description
  vpc_id            = module.stack.vpc_id
  certificate_arn   = data.aws_iam_server_certificate.wildcard.arn
  hosts             = var.admin_hosts
  public_subnet_az1 = module.stack.public_subnet_az1
  public_subnet_az2 = module.stack.public_subnet_az2
  security_group    = module.stack.restricted_web_traffic_security_group
  log_bucket_name   = var.log_bucket_name
}

module "elasticache_broker_network" {
  source                     = "../../modules/elasticache_broker_network"
  stack_description          = var.stack_description
  elasticache_private_cidr_1 = cidrsubnet(var.vpc_cidr, 8, 34)
  elasticache_private_cidr_2 = cidrsubnet(var.vpc_cidr, 8, 35)
  az1_route_table            = module.stack.private_route_table_az1
  az2_route_table            = module.stack.private_route_table_az2
  vpc_id                     = module.stack.vpc_id
  security_groups            = [module.stack.bosh_security_group]
  elb_subnets                = [module.cf.services_subnet_az1, module.cf.services_subnet_az2]
  elb_security_groups        = [module.stack.bosh_security_group]
  log_bucket_name            = var.log_bucket_name
}

module "elasticsearch_broker" {
  source                       = "../../modules/elasticsearch_broker"
  stack_description            = var.stack_description
  elasticsearch_private_cidr_1 = cidrsubnet(var.vpc_cidr, 8, 40)
  elasticsearch_private_cidr_2 = cidrsubnet(var.vpc_cidr, 8, 42)
  az1_route_table              = module.stack.private_route_table_az1
  az2_route_table              = module.stack.private_route_table_az2
  vpc_id                       = module.stack.vpc_id
  security_groups              = [module.stack.bosh_security_group]
}

module "external_domain_broker_govcloud" {
  source = "../../modules/external_domain_broker_govcloud"

  account_id        = data.aws_caller_identity.current.account_id
  stack_description = var.stack_description
}


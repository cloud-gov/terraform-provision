terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias             = "tooling"
  use_fips_endpoint = true

  default_tags {
    tags = {
      deployment = "bosh-tooling"
    }
  }
}

provider "aws" {
  use_fips_endpoint = true
  region            = var.aws_default_region
  assume_role {
    role_arn = var.assume_arn
  }
  default_tags {
    tags = {
      deployment = "regional-master-bosh-${var.stack_description}"
      stack      = "${var.stack_description}"
    }
  }
}

data "aws_partition" "current" {
}

data "aws_caller_identity" "current" {
}
data "aws_caller_identity" "tooling" {
  provider = aws.tooling
}

data "aws_availability_zones" "available" {
}

data "aws_region" "current" {
}

data "terraform_remote_state" "target_vpc" {
  # N.B. according to this issue comment https://github.com/hashicorp/terraform/issues/18611#issuecomment-410883474
  # the backend here should use the default credentials, which actually belong to the aws.tooling provider.
  # This is what we want, since we're trying to get the tooling state from a bucket in tooling as a tooling user.

  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = "${var.target_stack_name}/terraform.tfstate"
  }
}

data "aws_iam_server_certificate" "wildcard_production" {
  name_prefix = var.wildcard_production_certificate_name_prefix
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

module "stack" {
  source = "../../modules/stack/base"

  stack_description                 = var.stack_description
  vpc_cidr                          = var.vpc_cidr
  az1                               = data.aws_availability_zones.available.names[0]
  az2                               = data.aws_availability_zones.available.names[1]
  aws_default_region                = var.aws_default_region
  public_cidr_1                     = cidrsubnet(var.vpc_cidr, 8, 100)
  public_cidr_2                     = cidrsubnet(var.vpc_cidr, 8, 101)
  private_cidr_1                    = cidrsubnet(var.vpc_cidr, 8, 1)
  private_cidr_2                    = cidrsubnet(var.vpc_cidr, 8, 2)
  restricted_ingress_web_cidrs      = var.restricted_ingress_web_cidrs
  restricted_ingress_web_ipv6_cidrs = var.restricted_ingress_web_ipv6_cidrs
  rds_private_cidr_1                = cidrsubnet(var.vpc_cidr, 8, 20)
  rds_private_cidr_2                = cidrsubnet(var.vpc_cidr, 8, 21)
  rds_private_cidr_3                = cidrsubnet(var.vpc_cidr, 7, 11) # This will give 22-23
  rds_private_cidr_4                = cidrsubnet(var.vpc_cidr, 7, 12) # This will give 24-25
  rds_password                      = var.rds_password
  credhub_rds_password              = var.credhub_rds_password
  rds_multi_az                      = var.rds_multi_az
  rds_security_groups               = [module.stack.bosh_security_group]
  rds_security_groups_count         = "1"
  rds_instance_type                 = var.rds_instance_type
  rds_db_engine_version             = var.rds_db_engine_version
  rds_parameter_group_family        = var.rds_parameter_group_family
  rds_allow_major_version_upgrade   = var.rds_allow_major_version_upgrade
  rds_apply_immediately             = var.rds_apply_immediately
  bosh_default_ssh_public_key       = var.bosh_default_ssh_public_key
  target_monitoring_security_group_cidrs = [
    data.terraform_remote_state.target_vpc.outputs.production_monitoring_subnet_cidr,
    data.terraform_remote_state.target_vpc.outputs.staging_monitoring_subnet_cidr,
  ]

  target_concourse_security_group_cidrs = [
    data.terraform_remote_state.target_vpc.outputs.production_concourse_subnet_cidr,
    data.terraform_remote_state.target_vpc.outputs.staging_concourse_subnet_cidr,
  ]
  rds_allowed_cidrs = [
    data.terraform_remote_state.target_vpc.outputs.production_concourse_subnet_cidr,
    data.terraform_remote_state.target_vpc.outputs.staging_concourse_subnet_cidr,
  ]

  target_credhub_security_group_cidrs = [
    data.terraform_remote_state.target_vpc.outputs.production_credhub_subnet_cidr,
    data.terraform_remote_state.target_vpc.outputs.staging_credhub_subnet_cidr,
  ]
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

module "concourse_vpc_peering" {
  # allow concourse to talk to regionalmasterbosh and its databases
  source = "../../modules/vpc_peering"

  providers = {
    aws         = aws
    aws.tooling = aws.tooling
  }
  target_vpc_account_id  = data.aws_caller_identity.tooling.account_id
  target_vpc_id          = data.terraform_remote_state.target_vpc.outputs.vpc_id
  target_vpc_cidr        = data.terraform_remote_state.target_vpc.outputs.vpc_cidr
  target_az1_route_table = data.terraform_remote_state.target_vpc.outputs.private_route_table_az1
  target_az2_route_table = data.terraform_remote_state.target_vpc.outputs.private_route_table_az2
  source_vpc_id          = module.stack.vpc_id
  source_vpc_cidr        = module.stack.vpc_cidr
  source_az1_route_table = module.stack.private_route_table_az1
  source_az2_route_table = module.stack.private_route_table_az2
}

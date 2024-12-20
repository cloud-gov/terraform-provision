terraform {
  backend "s3" {
  }
}

provider "aws" {
  use_fips_endpoint = true
  # this is for CI
  # run deployments, provide jumpboxes, check on things, etc
  alias = "tooling"
  default_tags {
    tags = {
      deployment = "bosh-tooling"
    }
  }
}
provider "aws" {
  use_fips_endpoint = true
  # this is for the tooling bosh
  # deploy and monitor vms, scrape metrics, compliance agents, and smtp
  alias  = "parentbosh"
  region = var.aws_default_region
  assume_role {
    role_arn = var.parent_assume_arn
  }
  default_tags {
    tags = {
      deployment = "bosh-parent"
    }
  }
}
provider "aws" {
  use_fips_endpoint = true
  region            = var.aws_default_region

  endpoints {
    # see https://github.com/hashicorp/terraform-provider-aws/issues/23619#issuecomment-1100198434
    route53resolver = "https://route53resolver.${var.aws_default_region}.amazonaws.com"
    waf             = "https://waf-regional-fips.${var.aws_default_region}.amazonaws.com"
  }

  assume_role {
    role_arn = var.assume_arn
  }
  default_tags {
    tags = {
      deployment = "cf-${var.stack_description}"
      stack      = "${var.stack_description}"
    }
  }
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

data "terraform_remote_state" "parent_vpc" {
  # N.B. according to this issue comment https://github.com/hashicorp/terraform/issues/18611#issuecomment-410883474
  # the backend here should use the default credentials, which actually belong to the aws.tooling provider.
  # This is what we want, since we're trying to get the tooling state from a bucket in tooling as a tooling user.

  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = "${var.parent_stack_name}/terraform.tfstate"
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

data "aws_iam_server_certificate" "pages" {
  for_each    = var.pages_cert_patterns
  name_prefix = each.key
  latest      = true
}

data "aws_iam_server_certificate" "pages_wildcard" {
  for_each    = var.pages_cert_patterns
  name_prefix = "star.${each.key}"
  latest      = true
}

data "aws_iam_server_certificate" "pages_wildcard_sites" {
  for_each    = var.pages_cert_patterns
  name_prefix = "star.sites.${each.key}"
  latest      = true
}

data "aws_caller_identity" "tooling" {
  provider = aws.tooling
}

data "aws_arn" "parent_role_arn" {
  arn = var.parent_assume_arn
}

data "aws_prefix_list" "s3_gw_cidrs" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

locals {
  pages_cert_ids = [for k, cert in data.aws_iam_server_certificate.pages : cert.arn]
  pages_wildcard_cert_ids = concat(
    [for k, cert in data.aws_iam_server_certificate.pages_wildcard : cert.arn],
    [for k, cert in data.aws_iam_server_certificate.pages_wildcard_sites : cert.arn]
  )
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
  ssl_policy        = var.aws_lb_listener_ssl_policy
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

  providers = {
    aws         = aws
    aws.tooling = aws.tooling
    aws.parent  = aws.parentbosh
  }
  stack_description                       = var.stack_description
  aws_partition                           = data.aws_partition.current.partition
  vpc_cidr                                = var.vpc_cidr
  az1                                     = data.aws_availability_zones.available.names[var.az1_index]
  az2                                     = data.aws_availability_zones.available.names[var.az2_index]
  aws_default_region                      = var.aws_default_region
  rds_db_size                             = var.rds_db_size
  rds_apply_immediately                   = var.rds_apply_immediately
  rds_allow_major_version_upgrade         = var.rds_allow_major_version_upgrade
  rds_instance_type                       = var.rds_instance_type
  rds_db_engine_version                   = var.rds_db_engine_version
  rds_parameter_group_family              = var.rds_parameter_group_family
  public_cidr_1                           = cidrsubnet(var.vpc_cidr, 8, 100)
  public_cidr_2                           = cidrsubnet(var.vpc_cidr, 8, 101)
  private_cidr_1                          = cidrsubnet(var.vpc_cidr, 8, 1)
  private_cidr_2                          = cidrsubnet(var.vpc_cidr, 8, 2)
  rds_private_cidr_1                      = cidrsubnet(var.vpc_cidr, 8, 20)
  rds_private_cidr_2                      = cidrsubnet(var.vpc_cidr, 8, 21)
  rds_private_cidr_3                      = cidrsubnet(var.vpc_cidr, 7, 11) # This will give 22-23
  rds_private_cidr_4                      = cidrsubnet(var.vpc_cidr, 7, 12) # This will give 24-25
  restricted_ingress_web_cidrs            = var.restricted_ingress_web_cidrs
  restricted_ingress_web_ipv6_cidrs       = var.restricted_ingress_web_ipv6_cidrs
  rds_password                            = var.rds_password
  credhub_rds_password                    = var.credhub_rds_password
  rds_db_engine_version_bosh_credhub      = var.rds_db_engine_version_bosh_credhub
  rds_parameter_group_family_bosh_credhub = var.rds_parameter_group_family_bosh_credhub


  parent_account_id           = data.aws_arn.parent_role_arn.account
  target_account_id           = data.aws_caller_identity.tooling.account_id
  bosh_default_ssh_public_key = var.bosh_default_ssh_public_key
  s3_gateway_policy_accounts  = var.s3_gateway_policy_accounts
  cidr_blocks                 = var.cidr_blocks

  target_vpc_id          = data.terraform_remote_state.target_vpc.outputs.vpc_id
  target_vpc_cidr        = data.terraform_remote_state.target_vpc.outputs.production_concourse_subnet_cidr
  target_az1_route_table = data.terraform_remote_state.target_vpc.outputs.private_route_table_az1
  target_az2_route_table = data.terraform_remote_state.target_vpc.outputs.private_route_table_az2

  target_concourse_security_group_cidrs = [
    data.terraform_remote_state.target_vpc.outputs.production_concourse_subnet_cidr,
    data.terraform_remote_state.target_vpc.outputs.staging_concourse_subnet_cidr,
    data.terraform_remote_state.target_vpc.outputs.private_subnet_az1_cidr,
  ]

  parent_vpc_id              = data.terraform_remote_state.parent_vpc.outputs.vpc_id
  parent_vpc_cidr            = data.terraform_remote_state.parent_vpc.outputs.vpc_cidr
  parent_bosh_security_group = data.terraform_remote_state.parent_vpc.outputs.bosh_security_group
  parent_az1_route_table     = data.terraform_remote_state.parent_vpc.outputs.private_route_table_az1
  parent_az2_route_table     = data.terraform_remote_state.parent_vpc.outputs.private_route_table_az2

  parent_monitoring_security_group_cidrs = [
    data.terraform_remote_state.parent_vpc.outputs.production_monitoring_subnet_cidr,
  ]

}

module "cf" {
  source = "../../modules/cloudfoundry"

  az1                     = data.aws_availability_zones.available.names[var.az1_index]
  az2                     = data.aws_availability_zones.available.names[var.az2_index]
  stack_description       = var.stack_description
  aws_partition           = data.aws_partition.current.partition
  elb_main_cert_id        = data.aws_iam_server_certificate.wildcard.arn
  elb_apps_cert_id        = data.aws_iam_server_certificate.wildcard_apps.arn
  pages_cert_ids          = local.pages_cert_ids
  pages_wildcard_cert_ids = local.pages_wildcard_cert_ids
  elb_subnets             = [module.stack.public_subnet_az1, module.stack.public_subnet_az2]

  elb_security_groups = [
    var.force_restricted_network == "no" ? module.stack.web_traffic_security_group : module.stack.restricted_web_traffic_security_group,
  ]

  rds_password               = var.cf_rds_password
  rds_subnet_group           = module.stack.rds_subnet_group
  rds_security_groups        = [module.stack.rds_postgres_security_group]
  rds_instance_type          = var.cf_rds_instance_type
  stack_prefix               = "cf-${var.stack_description}"
  rds_db_engine_version      = var.rds_db_engine_version_cf
  rds_parameter_group_family = var.rds_parameter_group_family_cf


  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_apply_immediately           = var.rds_apply_immediately

  vpc_id                  = module.stack.vpc_id
  private_route_table_az1 = module.stack.private_route_table_az1
  private_route_table_az2 = module.stack.private_route_table_az2

  services_cidr_1 = cidrsubnet(var.vpc_cidr, 8, 30)
  services_cidr_2 = cidrsubnet(var.vpc_cidr, 8, 31)
  bucket_prefix   = var.bucket_prefix
  log_bucket_name = module.log_bucket.elb_bucket_name

  tcp_lb_count                            = var.include_tcp_routes ? 1 : 0
  tcp_allow_cidrs_ipv4                    = var.force_restricted_network == "no" ? ["0.0.0.0/0"] : var.restricted_ingress_web_cidrs
  tcp_allow_cidrs_ipv6                    = var.force_restricted_network == "no" ? ["::/0"] : var.restricted_ingress_web_ipv6_cidrs
  waf_regular_expressions                 = var.waf_regular_expressions
  waf_drop_logs_hosts_regular_expressions = var.waf_drop_logs_hosts_regular_expressions
  waf_regex_rules                         = var.waf_regex_rules

  scope_down_known_bad_inputs_not_match_uri_path_regex_string = var.scope_down_known_bad_inputs_not_match_uri_path_regex_string
  scope_down_known_bad_inputs_not_match_origin_search_string  = var.scope_down_known_bad_inputs_not_match_origin_search_string
  waf_drop_logs_label                                         = var.waf_drop_logs_label
  waf_drop_logs_hostnames                                     = var.waf_drop_logs_hostnames

  ## TODO: manage these IP sets in Terraform somewhere
  gsa_ip_range_ip_set_arn                     = var.gsa_ip_range_ip_set_arn
  api_data_gov_hosts_regex_pattern_arn        = var.api_data_gov_hosts_regex_pattern_arn
  customer_whitelist_ip_ranges_set_arn        = var.customer_whitelist_ip_ranges_set_arn
  customer_whitelist_source_ip_ranges_set_arn = var.customer_whitelist_source_ip_ranges_set_arn
  malicious_ja3_fingerprint_ids               = var.malicious_ja3_fingerprint_ids
  internal_vpc_cidrs_set_arn                  = var.internal_vpc_cidrs_set_arn
  cg_egress_ip_set_arn                        = var.cg_egress_ip_set_arn

  loadbalancer_forward_original_weight = var.loadbalancer_forward_original_weight
  loadbalancer_forward_new_weight      = var.loadbalancer_forward_new_weight
  aws_lb_listener_ssl_policy           = var.aws_lb_listener_ssl_policy
}


module "autoscaler" {
  source = "../../modules/autoscaler"

  stack_description               = var.stack_description
  rds_password                    = random_string.autoscaler_rds_password.result
  rds_subnet_group                = module.stack.rds_subnet_group
  rds_security_groups             = [module.stack.rds_postgres_security_group]
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_apply_immediately           = var.rds_apply_immediately
  rds_instance_type               = var.cf_as_rds_instance_type

}

resource "random_string" "autoscaler_rds_password" {
  length      = 32
  special     = false
  min_special = 0
  min_upper   = 5
  min_numeric = 5
  min_lower   = 5
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

  log_bucket_name = module.log_bucket.elb_bucket_name
}

module "logsearch" {
  source = "../../modules/logsearch"

  stack_description   = var.stack_description
  vpc_id              = module.stack.vpc_id
  private_elb_subnets = [module.cf.services_subnet_az1, module.cf.services_subnet_az2]
  bosh_security_group = module.stack.bosh_security_group
  listener_arn        = aws_lb_listener.main.arn
  hosts               = var.platform_kibana_hosts
  elb_log_bucket_name = module.log_bucket.elb_bucket_name
  aws_partition       = data.aws_partition.current.partition
}

module "shibboleth" {
  source = "../../modules/shibboleth"

  stack_description = var.stack_description
  vpc_id            = module.stack.vpc_id
  listener_arn      = aws_lb_listener.main.arn
  hosts             = var.shibboleth_hosts
}

module "elasticache_broker_network" {
  source                     = "../../modules/elasticache_broker_network"
  az1                        = data.aws_availability_zones.available.names[var.az1_index]
  az2                        = data.aws_availability_zones.available.names[var.az2_index]
  stack_description          = var.stack_description
  elasticache_private_cidr_1 = cidrsubnet(var.vpc_cidr, 8, 34)
  elasticache_private_cidr_2 = cidrsubnet(var.vpc_cidr, 8, 35)
  az1_route_table            = module.stack.private_route_table_az1
  az2_route_table            = module.stack.private_route_table_az2
  vpc_id                     = module.stack.vpc_id
  security_groups            = [module.stack.bosh_security_group]
  elb_subnets                = [module.cf.services_subnet_az1, module.cf.services_subnet_az2]
  elb_security_groups        = [module.stack.bosh_security_group]
  log_bucket_name            = module.log_bucket.elb_bucket_name
}

module "elasticsearch_broker" {
  source                       = "../../modules/elasticsearch_broker"
  stack_description            = var.stack_description
  az1                          = data.aws_availability_zones.available.names[var.az1_index]
  az2                          = data.aws_availability_zones.available.names[var.az2_index]
  elasticsearch_private_cidr_1 = cidrsubnet(var.vpc_cidr, 8, 40)
  elasticsearch_private_cidr_2 = cidrsubnet(var.vpc_cidr, 8, 42)
  elasticsearch_private_cidr_3 = cidrsubnet(var.vpc_cidr, 7, 25)
  elasticsearch_private_cidr_4 = cidrsubnet(var.vpc_cidr, 7, 27)
  az1_route_table              = module.stack.private_route_table_az1
  az2_route_table              = module.stack.private_route_table_az2
  vpc_id                       = module.stack.vpc_id
  security_groups              = [module.stack.bosh_security_group]
}

module "external_domain_broker_govcloud" {
  source = "../../modules/external_domain_broker_govcloud"

  account_id        = data.aws_caller_identity.current.account_id
  stack_description = var.stack_description
  aws_region        = data.aws_region.current.name
  aws_partition     = data.aws_partition.current.partition
}

module "dns_logging" {
  source = "../../modules/dns_logging"

  stack_description = var.stack_description
  vpc_id            = module.stack.vpc_id
  aws_partition     = data.aws_partition.current.partition
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  stack_description                   = var.stack_description
  cg_platform_notifications_arn       = module.sns.cg_platform_notifications_arn
  cg_platform_slack_notifications_arn = module.sns.cg_platform_slack_notifications_arn
  load_balancer_dns                   = module.cf.lb_arn_suffix
  aws_partition                       = data.aws_partition.current.partition
}

module "sns" {
  source = "../../modules/sns"

  sns_cg_platform_notifications_name        = "${var.stack_description}-platform-notifications"
  sns_cg_platform_notifications_email       = var.sns_cg_platform_notifications_email
  sns_cg_platform_slack_notifications_name  = "${var.stack_description}-platform-slack-notifications"
  sns_cg_platform_slack_notifications_email = var.sns_cg_platform_slack_notifications_email
}

module "csb_iam" {
  source = "../../modules/csb/iam"

  stack_description = var.stack_description
}

resource "random_password" "csb_rds_password" {
  length      = 32
  special     = false
  min_special = 0
  min_upper   = 5
  min_numeric = 5
  min_lower   = 5
}

module "csb_broker" {
  count = var.stack_description == "development" ? 1 : 0

  source              = "../../modules/csb/broker"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.aws_default_region

  rds_password        = random_password.csb_rds_password.result
  rds_subnet_group    = module.stack.rds_subnet_group
  rds_security_groups = [module.stack.rds_mysql_security_group]

  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_apply_immediately           = var.rds_apply_immediately
  rds_instance_type               = var.csb_rds_instance_type

  stack_description = var.stack_description
  ecr_stack_name    = var.ecr_stack_name
}

module "opensearch_proxy_redis_cluster" {
  source = "../../modules/elasticache_replication_group"

  cluster_name       = "${var.stack_description}-opensearch-proxy"
  subnet_group_name  = module.elasticache_broker_network.elasticache_subnet_group
  security_group_ids = [module.elasticache_broker_network.elasticache_redis_security_group]
}

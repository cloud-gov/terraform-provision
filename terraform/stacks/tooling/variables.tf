variable "stack_description" {
  default = "tooling"
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "vpc_cidr" {
}

variable "rds_password" {
  sensitive = true
}

variable "credhub_rds_password" {
  sensitive = true
}

variable "rds_multi_az" {
  default = "true"
}

variable "rds_allow_major_version_upgrade" {
  default = "false"
}

variable "rds_apply_immediately" {
  default = "false"
}

variable "rds_db_engine_version" {
  default = "12.19"
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_db_engine_version_bosh" {
  default = "15.5"
}

variable "rds_parameter_group_family_bosh" {
  default = "postgres15"
}

variable "rds_shared_preload_libraries_bosh" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_bosh" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_db_engine_version_credhub_staging" {
  default = "15.5"
}

variable "rds_parameter_group_family_credhub_staging" {
  default = "postgres15"
}
variable "rds_shared_preload_libraries_credhub_staging" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_credhub_staging" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_db_engine_version_credhub_production" {
  default = "15.5"
}

variable "rds_parameter_group_family_credhub_production" {
  default = "postgres15"
}

variable "rds_shared_preload_libraries_credhub_production" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_credhub_production" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_db_engine_version_concourse_staging" {
  default = "15.5"
}

variable "rds_parameter_group_family_concourse_staging" {
  default = "postgres15"
}

variable "rds_shared_preload_libraries_concourse_staging" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_concourse_staging" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_db_engine_version_concourse_production" {
  default = "15.5"
}

variable "rds_parameter_group_family_concourse_production" {
  default = "postgres15"
}

variable "rds_shared_preload_libraries_concourse_production" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_concourse_production" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_db_engine_version_opsuaa" {
  default = "16.1"
}

variable "rds_parameter_group_family_opsuaa" {
  default = "postgres16"
}

variable "rds_shared_preload_libraries_opsuaa" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_opsuaa" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "firewall_inspection_remote_state_bucket" {
}

variable "concourse_prod_rds_password" {
  sensitive = true
}

variable "concourse_prod_pages_rds_password" {
  sensitive = true
}

variable "concourse_staging_rds_password" {
  sensitive = true
}

variable "concourse_varz_bucket" {
}

variable "credhub_prod_rds_password" {
  sensitive = true
}

variable "credhub_staging_rds_password" {
  sensitive = true
}

variable "defectdojo_development_rds_password" {
  sensitive = true
}

variable "defectdojo_staging_rds_password" {
  sensitive = true
}

variable "defectdojo_production_rds_password" {
  sensitive = true
}

variable "wildcard_production_certificate_name_prefix" {
  default = ""
}

variable "wildcard_staging_certificate_name_prefix" {
  default = ""
}

variable "wildcard_development_certificate_name_prefix" {
  default = ""
}

variable "concourse_production_hosts" {
  type = list(string)
}

variable "concourse_staging_hosts" {
  type = list(string)
}

variable "credhub_production_hosts" {
  type = list(string)
}

variable "credhub_staging_hosts" {
  type = list(string)
}

variable "defectdojo_development_hosts" {
  type = list(string)
}

variable "defectdojo_staging_hosts" {
  type = list(string)
}

variable "defectdojo_production_hosts" {
  type = list(string)
}

variable "monitoring_production_hosts" {
  type = list(string)
}

variable "monitoring_staging_hosts" {
  type = list(string)
}

variable "monitoring_workshop_hosts" {
  type = list(string)
}

variable "monitoring_pages_hosts" {
  type = list(string)
}

variable "nessus_hosts" {
  type = list(string)
}

variable "restricted_ingress_web_cidrs" {
  type = list(string)
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type = list(string)
}

variable "blobstore_bucket_name" {
}

variable "bucket_prefix" {
  default = ""
}

variable "dns_eip_count_production" {
  default = 4
}

variable "dns_eip_count_staging" {
  default = 2
}

variable "varz_bucket" {
  default = "cloud-gov-varz"
}

variable "varz_bucket_stage" {
  default = "cloud-gov-varz-stage"
}

variable "bosh_release_bucket" {
  default = "cloud-gov-bosh-releases"
}

variable "terraform_state_bucket" {
  default = "terraform-state"
}

variable "semver_bucket" {
  default = "cg-semver"
}

variable "build_artifacts_bucket" {
  default = "cg-build-artifacts"
}

variable "buildpack_notify_bucket" {
  default = "buildpack-notify-state-*"
}

variable "billing_bucket" {
  default = "cg-billing-*"
}

variable "cg_binaries_bucket" {
  default = "cg-binaries"
}

variable "smtp_ingress_cidr_blocks" {
  type = list(string)
}

variable "cloudtrail_bucket" {
  default = "cg-s3-cloudtrail"
}

variable "cloudtrail_accesslog_bucket" {
  default = "cg-accesslogs"
}

variable "log_bucket_name" {
  default = "cg-elb-logs"
}

variable "container_scanning_bucket_name" {
  default = "cg-container-scanning"
}

variable "nessus_oidc_client" {
}

variable "nessus_oidc_client_secret" {
}

variable "doomsday_oidc_client" {
}

variable "doomsday_oidc_client_secret" {
}

variable "opslogin_hostname" {
}

variable "bosh_default_ssh_public_key" {

}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}

variable "github_backups_bucket_name" {
  type    = string
  default = "github-backups"
}

variable "rds_db_engine_version_bosh_credhub" {
  default = "15.5"
}

variable "rds_parameter_group_family_bosh_credhub" {
  default = "postgres15"
}

variable "rds_shared_preload_libraries_bosh_credhub" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_bosh_credhub" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "aws_lb_listener_ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
}

variable "rds_db_engine_version_defectdojo_development" {
  default = "16.3"
}

variable "rds_parameter_group_family_defectdojo_development" {
  default = "postgres16"
}

variable "rds_shared_preload_libraries_defectdojo_development" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_defectdojo_development" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_db_engine_version_defectdojo_staging" {
  default = "16.3"
}

variable "rds_parameter_group_family_defectdojo_staging" {
  default = "postgres16"
}

variable "rds_shared_preload_libraries_defectdojo_staging" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_defectdojo_staging" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "rds_db_engine_version_defectdojo_production" {
  default = "16.3"
}

variable "rds_parameter_group_family_defectdojo_production" {
  default = "postgres16"
}

variable "rds_shared_preload_libraries_defectdojo_production" {
  description = "List of shared_preload_libraries to load"
  type        = string
  default     = "pg_stat_statements"
}

variable "rds_pgaudit_log_values_defectdojo_production" {
  description = "List of statements that should be included in pgaudit logs"
  type        = string
  default     = "none"
}

variable "fips_stemcell_bucket" {
  type    = string
  default = "fips-stemcell"
}

variable "attach_to_inspection_vpc" {
  type        = bool
  default     = false
  description = "Phase one of a staged cutover onto the network firewall inspection VPC: build this stack's transit gateway subnets, attachment, and TGW routing, and leave them idle. No traffic moves. Safe to apply at any time, and the point at which the TGW path should be verified -- attachment available, this VPC's CIDR present in the inspection VPC's TGW route table, firewall endpoints healthy, and inspection_nat_egress_ips added to any external allowlist that currently names nat_egress_ip_az1/az2. Implied by egress_traffic_through_inspection_vpc, so setting only that flag still cuts over in a single apply."
}

variable "egress_traffic_through_inspection_vpc" {
  type        = bool
  default     = false
  description = "Phase two: route this stack's private-subnet egress through the network firewall inspection VPC instead of its own NAT gateways. Implies attach_to_inspection_vpc. This is the only step that moves traffic, and it resets established outbound TCP connections because the source address external services see changes to the inspection VPC's NAT EIPs. Schedule it."
}

variable "inspection_internal_cidrs" {
  type        = list(string)
  default     = []
  description = "Internal CIDRs that this stack's public subnets should reach over the inspection VPC's transit gateway rather than the internet gateway. Read only when egress_traffic_through_inspection_vpc is true. Leave empty to inspect private-subnet egress only; the public subnets' default route stays on the internet gateway either way so inbound traffic to the main load balancer keeps its return path. Set this to the CIDRs of the environments this stack needs to reach east-west -- not to this VPC's own CIDR, which is served by the implicit local route."
}

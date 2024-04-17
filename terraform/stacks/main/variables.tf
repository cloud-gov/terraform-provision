variable "stack_description" {
}

variable "aws_default_region" {
  default = "us-gov-west-1"
}

variable "aws_partition" {
  default = "us-gov"
}

variable "vpc_cidr" {
}

variable "rds_db_size" {
  default = 20
}

variable "rds_password" {
  sensitive = true
}

variable "rds_instance_type" {
  default = "db.m5.large"
}

variable "cf_rds_password" {
  sensitive = true
}

variable "credhub_rds_password" {
  sensitive = true
}

variable "remote_state_bucket" {
}

variable "target_stack_name" {
  default = "tooling"
}

variable "wildcard_certificate_name_prefix" {
  default = ""
}

variable "wildcard_apps_certificate_name_prefix" {
  default = ""
}

variable "pages_cert_patterns" {
  default = []
  type    = set(string)
}

variable "shibboleth_hosts" {
  type = list(string)
}

variable "platform_kibana_hosts" {
  type = list(string)
}

variable "restricted_ingress_web_cidrs" {
  type = list(string)
}

variable "restricted_ingress_web_ipv6_cidrs" {
  type = list(string)
}


variable "bucket_prefix" {
}

variable "blobstore_bucket_name" {
}

variable "upstream_blobstore_bucket_name" {
}

variable "force_restricted_network" {
  default = "yes"
}

variable "log_bucket_name" {
  default = "cg-elb-logs"
}

variable "rds_allow_major_version_upgrade" {
  default = "false"
}

variable "rds_apply_immediately" {
  default = "false"
}

variable "assume_arn" {
  # arn of a role to assume in the account being configured
}

variable "parent_assume_arn" {
  # arn of a role to assume in the account the parentbosh lives in
}

variable "parent_stack_name" {
  # stack where the parent bosh lives
  default = "tooling"
}

variable "domains_broker_rds_version" {
  default = "12.17"
}
variable "cf_rds_instance_type" {
  default = "db.m5.large"
}

variable "cf_as_rds_instance_type" {
  default = "db.t3.large"
}


variable "bosh_default_ssh_public_key" {

}

variable "az1_index" {
  default = "0"
}

variable "az2_index" {
  default = "1"
}

variable "include_tcp_routes" {
  type    = bool
  default = false
}

variable "waf_regular_expressions" {
  type = list(string)
}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}

variable "sns_name" {

}

variable "scope_down_known_bad_inputs_not_match_uri_path_regex_string" {
  type = string
}

variable "scope_down_known_bad_inputs_not_match_origin_search_string" {
  type = string
}

variable "waf_label_host_0" {
  type        = string
  description = "Label 0 for applying label to list 0 traffic"
}

variable "waf_hostnames_0" {
  type        = list(string)
  description = "List 0 for applying label 0 to traffic"
}

variable "logstash_hosts" {
  type = list(string)
}

variable "gsa_ip_range_ip_set_arn" {
  type        = string
  description = "ARN of IP set identifying GSA IP CIDR ranges"
}

variable "malicious_ja3_fingerprint_ids" {
  type        = list(string)
  description = "JA3 fingerprint IDs associated with malicious traffic"
}

variable "api_data_gov_hosts_regex_pattern_arn" {
  type        = string
  description = "ARN of regex pattern set used to identify hosts for api.data.gov"
}

variable "customer_whitelist_ip_ranges_set_arn" {
  type        = string
  description = "ARN of IP set identifying customer IP CIDR ranges that should be whitelisted by X-Forwarded-For header"
}

variable "customer_whitelist_source_ip_ranges_set_arn" {
  type        = string
  description = "ARN of IP set identifying customer IP CIDR ranges that should be whitelisted by source IP address"
}

variable "internal_vpc_cidrs_set_arn" {
  type        = string
  description = "ARN of IP set identifying IP CIDR ranges for VPCs"
}

variable "cg_egress_ip_set_arn" {
  type        = string
  description = "ARN of IP set identifying egress IP CIDR ranges for cloud.gov"
}

variable "cidr_blocks" {
  type    = list(string)
  default = []
}

variable "domains_lbgroup_count" {
}

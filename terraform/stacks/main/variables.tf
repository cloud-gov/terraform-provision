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

variable "rds_db_engine_version" {
  default = "12.19"
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_force_ssl" {
  default = 1
}

variable "rds_db_engine_version_autoscaler" {
  default = "15.7"
}

variable "rds_parameter_group_family_autoscaler" {
  default = "postgres15"
}

variable "rds_force_ssl_autoscaler" {
  default = 1
}

variable "rds_db_engine_version_cf" {
  default = "16.3"
}

variable "rds_parameter_group_family_cf" {
  default = "postgres16"
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
  default = "15.7"
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

variable "waf_drop_logs_hosts_regular_expressions" {
  type = list(string)
}

variable "s3_gateway_policy_accounts" {
  type    = list(string)
  default = []
}

variable "sns_cg_platform_notifications_email" {
  type        = string
  description = "Email to receive platform notifications"

}

variable "sns_cg_platform_slack_notifications_email" {
  type        = string
  description = "Email to receive platform slack notifications"
}

variable "scope_down_known_bad_inputs_not_match_uri_path_regex_string" {
  type = string
}

variable "scope_down_known_bad_inputs_not_match_origin_search_string" {
  type = string
}

variable "waf_drop_logs_label" {
  type        = string
  description = "Label for WAF rule that will drop logs based on hostname"
}

variable "waf_drop_logs_hostnames" {
  type        = list(string)
  description = "List of hostnames that should WAF logs dropped"
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

variable "loadbalancer_forward_original_weight" {
  type        = number
  description = "Weight of traffic to send to original target groups"
  default     = 100
}

variable "loadbalancer_forward_new_weight" {
  type        = number
  description = "Weight of traffic to send to original target groups"
  default     = 0
}


variable "rds_db_engine_version_bosh_credhub" {
  default = "15.5"
}

variable "rds_parameter_group_family_bosh_credhub" {
  default = "postgres15"
}

variable "waf_regex_rules" {
  type = list(object({
    # path_regex is matched against the uri path of a request
    # before comparison, the path is normalized (so self/parent path references are collapsed)
    path_regex = string
    # host_regex is matched against the host header on requests
    host_regex = string
    priority   = number
    # when block is true, requests matching the rules are blocked.
    # When false, they are instead counted
    block = bool
    # `name` is used for metrics and logging
    name = string
  }))
  description = "list of objects defining regular expression rules for waf"
  default     = []
}

variable "aws_lb_listener_ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
}

variable "csb_rds_instance_type" {
  type    = string
  default = "db.t3.small"
}

variable "ecr_stack_name" {
  type        = string
  description = "The name of the stack that configures ECR."
  default     = "ecr"
}

variable "bosh_blobstore_sse" {
  default = "AES256"
}

variable "defectdojo_development_rds_password" {
  sensitive = true
}

variable "defectdojo_development_hosts" {
  type = list(string)
}

variable "rds_db_engine_version_defectdojo_development" {
  default = "16.3"
}

variable "rds_parameter_group_family_defectdojo_development" {
  default = "postgres16"
}

variable "rds_force_ssl_defectdojo_development" {
  default = 1
}

variable "rds_multi_az" {
  default = "true"
}

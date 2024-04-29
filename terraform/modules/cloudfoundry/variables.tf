variable "elb_main_cert_id" {
}

variable "elb_apps_cert_id" {
}

variable "pages_cert_ids" {
  default = []
  type    = set(string)
}

variable "pages_wildcard_cert_ids" {
  default = []
  type    = set(string)
}

variable "elb_subnets" {
  type = list(string)
}

variable "elb_security_groups" {
  type = list(string)
}

variable "stack_description" {
}

variable "rds_instance_type" {
  default = "db.m5.large"
}

variable "rds_db_size" {
  default = 100
}

variable "rds_db_name" {
  default = "ccdb"
}

variable "rds_db_engine" {
  default = "postgres"
}

variable "rds_db_engine_version" {
  default = "12.17"
}

variable "rds_parameter_group_family" {
  default = "postgres12"
}

variable "rds_username" {
  default = "cfdb"
}

variable "rds_password" {
  sensitive = true
}

variable "rds_subnet_group" {
}

variable "rds_security_groups" {
  type = list(string)
}

variable "rds_apply_immediately" {
  default = "false"
}

variable "rds_allow_major_version_upgrade" {
  default = "false"
}

variable "stack_prefix" {
}

variable "az1" {
  default = "us-gov-west-1a"
}

variable "az2" {
  default = "us-gov-west-1b"
}

variable "vpc_id" {
}

variable "private_route_table_az1" {
}

variable "private_route_table_az2" {
}

variable "services_cidr_1" {
}

variable "services_cidr_2" {
}

variable "aws_partition" {
}

variable "bucket_prefix" {
}

variable "log_bucket_name" {
}

variable "tcp_lb_count" {
  default = 0
}

variable "listeners_per_tcp_lb" {
  default = 10
}

variable "tcp_first_port" {
  default = 10000
}

variable "tcp_allow_cidrs_ipv4" {
  default = ["0.0.0.0/0"]
}
variable "tcp_allow_cidrs_ipv6" {
  default = ["::/0"]
}

variable "waf_regular_expressions" {
  type = list(string)
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

variable "user_agent_header_name" {
  type        = string
  description = "Header name to identify user agent"
  default     = "user-agent"
}

variable "cloudfront_user_agent_header" {
  type        = string
  description = "User-Agent header value used to identify Cloudfront traffic"
  default     = "Amazon CloudFront"
}

variable "forwarded_ip_header_name" {
  type        = string
  description = "Header name used to get forwarded IP addresses"
  default     = "X-Forwarded-For"
}

variable "non_cdn_traffic_rate_limit_challenge_by_source_ip" {
  type        = number
  description = "Number of requests to allow per source IP per 5 minute interval before challenging requests"
  default     = 2000
}

variable "cdn_traffic_rate_limit_challenge_by_forwarded_ip" {
  type        = number
  description = "Number of requests to allow per forwarded IP per 5 minute interval before challenging requests"
  default     = 2000
}

variable "non_cdn_traffic_rate_limit_block_by_source_ip" {
  type        = number
  description = "Number of requests to allow per source IP per 5 minute interval before blocking requests"
  default     = 5000
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

variable "internal_logstash_hosts_regex_pattern_arn" {
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

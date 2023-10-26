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
  default = "db.m4.large"
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
  default = "12.14"
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

variable "waf_label_host_0" {
  type = string
}

variable "waf_hostname_0" {
  type = string
}

variable "nat_egress_ip_set_arn" {
  type    = string
  description = "ARN for IP set of CIDR ranges for NAT Gateways for this environment"
}

variable "tooling_nat_egress_ip_set_arn" {
  type    = string
  description = "ARN for IP set of CIDR ranges for NAT Gateways for the tooling environment"
}

variable "user_agent_header_name" {
  type = string
  description = "Header name to identify user agent"
  default = "user-agent"
}

variable "cloudfront_user_agent_header" {
  type = string
  description = "User-Agent header value used to identify Cloudfront traffic"
  default = "Amazon Cloudfront"
}

variable "forwarded_ip_header_name" {
  type = string
  description = "Header name used to get forwarded IP addresses"
  default = "X-Forwarded-For"
}

variable "non_cdn_traffic_rate_limit_challenge_by_source_ip" {
  type = integer
  description = "Number of requests to allow per source IP per 5 minute interval before challenging requests"
  default = 2000
}

variable "non_cdn_traffic_rate_limit_challenge_by_forwarded_ip" {
  type = integer
  description = "Number of requests to allow per forwarded IP per 5 minute interval before challenging requests"
  default = 2000
}

variable "non_cdn_traffic_rate_limit_block_by_forwarded_ip" {
  type = integer
  description = "Number of requests to allow per forwarded IP per 5 minute interval before blocking requests"
  default = 5000
}

variable "gsa_ip_range_ip_set_arn" {
  type = string
  description = "ARN of IP set identifying GSA IP CIDR ranges"
}

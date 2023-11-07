variable "route53_zone_id" {
  type        = string
  description = "Route53 zone ID to use for records"
}

variable "test_cdn_domain" {
  type        = string
  description = "Top-level domain to use for the test CDN record (e.g. fr-stage.cloud.gov)"
}

variable "test_cdn_subdomain" {
  type        = string
  description = "Subdomain for test CDN"
  default     = "test-cdn"
}

variable "external_domain_broker_env" {
  type        = string
  description = "External domain broker environment (e.g. staging, production)"
}

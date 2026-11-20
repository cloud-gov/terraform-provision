resource "aws_wafv2_web_acl" "admin_waf" {
  name        = "${var.stack_description}-admin-waf"
  description = "Admin WAF Rules"
  scope       = "REGIONAL"

  # Regarding tags_all, see https://github.com/hashicorp/terraform-provider-aws/issues/24386#issuecomment-1109340765
  lifecycle {
    # Regarding rule: If you make updates to the WAF rules in this file, you must remove `rule` so they apply.
    # This is a workaround to an issue: https://github.com/hashicorp/terraform-provider-aws/issues/33124
    ignore_changes = [rule, tags_all]
  }

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-core-metric"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "admin_anonymous_ip_list" {
  web_acl_arn = aws_wafv2_web_acl.admin_waf.arn
  name        = "AWS-AWSManagedRulesAnonymousIpList"
  priority    = 10

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesAnonymousIpList"
      vendor_name = "AWS"

      rule_action_override {
        action_to_use {
          block {}
        }

        name = "HostingProviderIPList"
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-AWS-AWSManagedRulesAnonymousIpList"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "admin_ip_reputation" {
  web_acl_arn = aws_wafv2_web_acl.admin_waf.arn
  name        = "AWS-AWSManagedRulesAmazonIpReputationList"
  priority    = 20

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesAmazonIpReputationList"
      vendor_name = "AWS"

      rule_action_override {
        action_to_use {
          block {}
        }

        name = "AWSManagedIPReputationList"
      }

      rule_action_override {
        action_to_use {
          block {}
        }

        name = "AWSManagedIPDDoSList"
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-AWS-ManagedRulesAmazonIpReputationList"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "admin_known_bad_inputs" {
  web_acl_arn = aws_wafv2_web_acl.admin_waf.arn
  name        = "AWS-KnownBadInputsRuleSet"
  priority    = 30

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-AWS-KnownBadInputsRuleSet"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "admin_core_rule_set" {
  web_acl_arn = aws_wafv2_web_acl.admin_waf.arn
  name        = "AWSManagedRule-CoreRuleSet"
  priority    = 40

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-AWS-AWSManagedRulesCommonRuleSet"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "admin_allow_trusted_ips" {
  web_acl_arn = aws_wafv2_web_acl.admin_waf.arn
  name        = "AllowTrustedIPs"
  priority    = 60

  action {
    allow {}
  }

  statement {
    or_statement {
      statement {
        ip_set_reference_statement {
          arn = var.cg_egress_ip_set_arn
        }
      }

      statement {
        ip_set_reference_statement {
          arn = var.gsa_ip_range_ip_set_arn
        }
      }

      statement {
        ip_set_reference_statement {
          arn = var.gsa_ipv6_range_ip_set_arn
        }
      }

      statement {
        ip_set_reference_statement {
          arn = var.customer_whitelist_source_ip_ranges_set_arn
        }
      }

      statement {
        ip_set_reference_statement {
          arn = var.cg_egress_ip_set_arn

          ip_set_forwarded_ip_config {
            header_name       = var.forwarded_ip_header_name
            fallback_behavior = "NO_MATCH"
            position          = "FIRST"
          }
        }
      }

      statement {
        ip_set_reference_statement {
          arn = var.gsa_ip_range_ip_set_arn

          ip_set_forwarded_ip_config {
            header_name       = var.forwarded_ip_header_name
            fallback_behavior = "NO_MATCH"
            position          = "FIRST"
          }
        }
      }

      statement {
        ip_set_reference_statement {
          arn = var.gsa_ipv6_range_ip_set_arn

          ip_set_forwarded_ip_config {
            header_name       = var.forwarded_ip_header_name
            fallback_behavior = "NO_MATCH"
            position          = "FIRST"
          }
        }
      }

      statement {
        ip_set_reference_statement {
          arn = var.internal_vpc_cidrs_set_arn

          ip_set_forwarded_ip_config {
            header_name       = var.forwarded_ip_header_name
            fallback_behavior = "NO_MATCH"
            position          = "FIRST"
          }
        }
      }

      statement {
        ip_set_reference_statement {
          arn = var.cg_egress_ip_set_arn

          ip_set_forwarded_ip_config {
            header_name       = var.forwarded_ip_header_name
            fallback_behavior = "NO_MATCH"
            position          = "FIRST"
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-AllowTrustedIPs"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "admin_anti_ddos" {
  web_acl_arn = aws_wafv2_web_acl.admin_waf.arn
  name        = "AWS-AWSManagedRulesAntiDDoSRuleSet"
  priority    = 80

  action {
    block {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesAntiDDoSRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-AntiDDoS"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "admin_rate_limit_challenge" {
  web_acl_arn = aws_wafv2_web_acl.admin_waf.arn
  name        = "RateLimitNonCDNBySourceIP-Challenge"
  priority    = 90

  action {
    challenge {}
  }

  statement {
    rate_based_statement {
      limit              = var.non_cdn_traffic_rate_limit_challenge_by_source_ip
      aggregate_key_type = "IP"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-RateLimitNonCDNBySourceIPChallenge"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "admin_rate_limit_block" {
  web_acl_arn = aws_wafv2_web_acl.admin_waf.arn
  name        = "RateLimitNonCDNBySourceIP-Block"
  priority    = 100

  action {
    block {}
  }

  statement {
    rate_based_statement {
      limit              = var.non_cdn_traffic_rate_limit_block_by_source_ip
      aggregate_key_type = "IP"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-admin-waf-RateLimitNonCDNBySourceIPBlock"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudwatch_log_group" "admin_waf_logs" {
  name              = "aws-waf-logs-admin-${var.stack_description}"
  retention_in_days = 365
  tags = {
    Environment = "${var.stack_description}"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "admin_waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.cf_uaa_waf_core_cloudwatch_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.admin_waf_arn.arn
}

locals {
  malicious_ja3_fingerprint_rules = [
    for idx, id in var.malicious_ja3_fingerprint_ids :
    { priority = idx + 70, fingerprint_id = id, key = idx }
  ]
}

// For webacl rules using AWS managed rule sets or custom rules, checkout the AWS Govcloud WAF V2 console
// Use the console to craft a sample webacl but before you commit you can click the tab/option to show you
// The rule in json format which will make it easier to translate to TF
// NOTE - webacl sets have rule capacity limits - make sure your total rule counts do not exceed the limit
//
// NOTE - Update documentation as you change WAF rule configuration:
// https://github.com/cloud-gov/cg-site/blob/main/_docs/technology/platform-protections.md

resource "aws_wafv2_web_acl" "cf_uaa_waf_core" {
  name        = "${var.stack_description}-cf-uaa-waf-core"
  description = "UAA ELB WAF Rules"
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

  # New rule for dropping logging for a specific set of hosts
  rule {
    name     = var.waf_drop_logs_label
    priority = 0
    action {
      allow {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = var.waf_drop_logs_label
      sampled_requests_enabled   = "true"
    }
    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.drop_logs_regex.arn
        field_to_match {
          single_header {
            name = "host"
          }
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
    rule_label {
      name = var.waf_drop_logs_label
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "HostingProviderIPList"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-AWS-AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
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
      metric_name                = "${var.stack_description}-AWS-ManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-KnownBadInputsRuleSet"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"

        scope_down_statement {
          and_statement {
            statement {
              not_statement {
                statement {
                  byte_match_statement {
                    search_string         = var.scope_down_known_bad_inputs_not_match_origin_search_string
                    positional_constraint = "EXACTLY"

                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }

                    field_to_match {
                      single_header {
                        name = "origin"
                      }
                    }
                  }
                }
              }
            }
            statement {
              not_statement {
                statement {
                  regex_match_statement {
                    regex_string = var.scope_down_known_bad_inputs_not_match_uri_path_regex_string

                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }

                    field_to_match {
                      uri_path {}
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-AWS-KnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRule-CoreRuleSet"
    priority = 40

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "CrossSiteScripting_COOKIE"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "CrossSiteScripting_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "EC2MetaDataSSRF_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "EC2MetaDataSSRF_QUERYARGUMENTS"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "GenericLFI_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "GenericRFI_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "GenericRFI_QUERYARGUMENTS"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "NoUserAgent_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_Cookie_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_QUERYSTRING"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_URIPATH"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "CG-RegexPatternSets"
    priority = 50
    action {
      block {}
    }
    statement {
      or_statement {
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.jndi_regex.arn
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.jndi_regex.arn
            field_to_match {
              query_string {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.jndi_regex.arn
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.jndi_regex.arn
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.jndi_regex.arn
            field_to_match {
              single_header {
                name = "accept"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-CG-RegexPatternSets"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AllowTrustedIPs"
    priority = 60

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

        statement {
          ip_set_reference_statement {
            arn = var.customer_whitelist_ip_ranges_set_arn

            ip_set_forwarded_ip_config {
              header_name       = var.forwarded_ip_header_name
              fallback_behavior = "NO_MATCH"
              position          = "FIRST"
            }
          }
        }

        statement {when I was a young warthog...}

        statement {
          ip_set_reference_statement {
            arn = var.gsa_ipv6_range_ip_set_arn
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-AllowTrustedIPs"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = toset(local.malicious_ja3_fingerprint_rules)
    iterator = rule

    content {
      name     = "BlockMaliciousJA3FingerprintID-${rule.value.key}"
      priority = rule.value.priority
      action {
        count {}
      }
      statement {
        byte_match_statement {
          field_to_match {
            ja3_fingerprint {
              fallback_behavior = "NO_MATCH"
            }
          }
          positional_constraint = "EXACTLY"
          search_string         = rule.value.fingerprint_id
          text_transformation {
            type     = "NONE"
            priority = 0
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.stack_description}-BlockMaliciousJA3FingerprintID-${rule.value.key}"
        sampled_requests_enabled   = true
      }
    }

  }

  dynamic "rule" {
    for_each = toset([for rule in var.waf_regex_rules : rule if rule.block])
    iterator = regex_rule

    content {
      name     = "BlockRegexRule-${regex_rule.value.name}"
      priority = regex_rule.value.priority
      action {
        block {}
      }
      statement {
        and_statement {
          statement {
            regex_match_statement {
              regex_string = regex_rule.value.path_regex
              field_to_match {
                uri_path {}
              }
              text_transformation {
                priority = 0
                type     = "NORMALIZE_PATH"
              }
            }
          }
          statement {
            regex_match_statement {
              regex_string = regex_rule.value.host_regex
              field_to_match {
                single_header {
                  name = "host"
                }
              }
              text_transformation {
                priority = 0
                type     = "LOWERCASE"
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.stack_description}-BlockRegexRule-${regex_rule.value.name}"
        sampled_requests_enabled   = true
      }
    }

  }

  dynamic "rule" {
    # this is identical to the dynamic rule above, except that the `action` is `count` instead of `block`
    for_each = toset([for rule in var.waf_regex_rules : rule if !rule.block])
    iterator = regex_rule

    content {
      name     = "BlockRegexRule-${regex_rule.value.name}"
      priority = regex_rule.value.priority
      action {
        count {}
      }
      statement {
        and_statement {
          statement {
            regex_match_statement {
              regex_string = regex_rule.value.path_regex
              field_to_match {
                uri_path {}
              }
              text_transformation {
                priority = 0
                type     = "NORMALIZE_PATH"
              }
            }
          }
          statement {
            regex_match_statement {
              regex_string = regex_rule.value.host_regex
              field_to_match {
                single_header {
                  name = "host"
                }
              }
              text_transformation {
                priority = 0
                type     = "LOWERCASE"
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.stack_description}-BlockRegexRule-${regex_rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "RateLimitNonCDNBySourceIP-Challenge"
    priority = 80

    action {
      challenge {}
    }

    statement {
      rate_based_statement {
        limit              = var.non_cdn_traffic_rate_limit_challenge_by_source_ip
        aggregate_key_type = "IP"

        scope_down_statement {
          and_statement {
            statement {
              not_statement {
                statement {
                  byte_match_statement {
                    field_to_match {
                      single_header {
                        name = var.user_agent_header_name
                      }
                    }

                    search_string         = var.cloudfront_user_agent_header
                    positional_constraint = "EXACTLY"

                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }

            statement {
              not_statement {
                statement {
                  regex_pattern_set_reference_statement {
                    arn = var.api_data_gov_hosts_regex_pattern_arn

                    field_to_match {
                      single_header {
                        name = "host"
                      }
                    }

                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-RateLimitNonCDNBySourceIPChallenge"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitCDNByForwardedIP-Challenge"
    priority = 90

    action {
      challenge {}
    }

    statement {
      rate_based_statement {
        limit              = var.cdn_traffic_rate_limit_challenge_by_forwarded_ip
        aggregate_key_type = "FORWARDED_IP"

        scope_down_statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = var.user_agent_header_name
              }
            }

            search_string         = var.cloudfront_user_agent_header
            positional_constraint = "EXACTLY"

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }

        forwarded_ip_config {
          fallback_behavior = "NO_MATCH"
          header_name       = var.forwarded_ip_header_name
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-RateLimitForwardedIPChallenge"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitNonCDNBySourceIP-Block"
    priority = 100

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = var.non_cdn_traffic_rate_limit_block_by_source_ip
        aggregate_key_type = "IP"

        scope_down_statement {
          and_statement {
            statement {
              not_statement {
                statement {
                  byte_match_statement {
                    field_to_match {
                      single_header {
                        name = var.user_agent_header_name
                      }
                    }

                    search_string         = var.cloudfront_user_agent_header
                    positional_constraint = "EXACTLY"

                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }

            statement {
              not_statement {
                statement {
                  regex_pattern_set_reference_statement {
                    arn = var.api_data_gov_hosts_regex_pattern_arn

                    field_to_match {
                      single_header {
                        name = "host"
                      }
                    }

                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-RateLimitNonCDNBySourceIPBlock"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-cf-uaa-waf-core-metric"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudwatch_log_group" "cf_uaa_waf_core_cloudwatch_log_group" {
  name              = "aws-waf-logs-${var.stack_description}"
  retention_in_days = 365
  tags = {
    Environment = "${var.stack_description}"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "cf_uaa_waf_core" {
  log_destination_configs = [aws_cloudwatch_log_group.cf_uaa_waf_core_cloudwatch_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.cf_uaa_waf_core.arn

  logging_filter {
    default_behavior = "KEEP"
    filter {
      behavior = "DROP"
      condition {
        label_name_condition {
          label_name = "awswaf:${data.aws_caller_identity.current.account_id}:webacl:${var.stack_description}-cf-uaa-waf-core:${var.waf_drop_logs_label}"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}

resource "aws_wafv2_web_acl_association" "cf_uaa_waf_core" {
  resource_arn = aws_lb.cf_uaa.arn
  web_acl_arn  = aws_wafv2_web_acl.cf_uaa_waf_core.arn
}

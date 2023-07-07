resource "aws_lb" "cf_uaa" {
  name            = "${var.stack_description}-cloudfoundry-uaa"
  subnets         = var.elb_subnets
  security_groups = var.elb_security_groups
  ip_address_type = "dualstack"
  idle_timeout    = 3600

  enable_deletion_protection = true

  access_logs {
    bucket  = var.log_bucket_name
    prefix  = var.stack_description
    enabled = true
  }
}

resource "aws_lb_target_group" "cf_uaa_target" {
  name     = "${var.stack_description}-cf-uaa"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    port                = 81
    timeout             = 4
    unhealthy_threshold = 3
    matcher             = 200
  }
}

resource "aws_lb_listener" "cf_uaa" {
  load_balancer_arn = aws_lb.cf_uaa.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
  certificate_arn   = var.elb_main_cert_id

  default_action {
    target_group_arn = aws_lb_target_group.cf_uaa_target.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "cf_uaa_http" {
  load_balancer_arn = aws_lb.cf_uaa.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cf_uaa_target.arn
    type             = "forward"
  }
}

// For webacl rules using AWS managed rule sets or custom rules, checkout the AWS Govcloud WAF V2 console
// Use the console to craft a sample webacl but before you commit you can click the tab/option to show you
// The rule in json format which will make it easier to translate to TF
// NOTE - webacl sets have rule capacity limits - make sure your total rule counts do not exceed the limit
resource "aws_wafv2_web_acl" "cf_uaa_waf_core" {
  name        = "${var.stack_description}-cf-uaa-waf-core"
  description = "UAA ELB WAF Rules"
  scope       = "REGIONAL"

  # see https://github.com/hashicorp/terraform-provider-aws/issues/24386#issuecomment-1109340765
  lifecycle {
    ignore_changes = [tags_all]
  }

  default_action {
    allow {}
  }

  # New rule for dropping logging for a specific host

  rule {
    name     = var.waf_label_host_0
    priority = 0

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }

        positional_constraint = "CONTAINS"
        search_string         = var.waf_hostname_0

        text_transformation {
          priority = "0"
          type     = "NONE"
        }
      }
    }

    rule_label {
      name = var.waf_label_host_0
    }

    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = var.waf_label_host_0
      sampled_requests_enabled   = "true"
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 1

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
    priority = 2

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
    priority = 3

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
    priority = 4

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
    name     = "RateLimitByForwardedHeader"
    priority = 5

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 250000
        aggregate_key_type = "FORWARDED_IP"

        forwarded_ip_config {
          # Match status to apply if the request doesn’t have a valid IP address in the specified position.
          # Note that, if the specified header isn’t present at all in the request, AWS WAF doesn’t apply
          # the rule to the request. (From AWS Console)
          fallback_behavior = "MATCH"
          header_name       = "X-Forwarded-For"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.stack_description}-RateLimitNonCDN"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "CG-RegexPatternSets"
    priority = 6
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
      metric_name                = "${var.stack_description}-AWS-AWSManagedRulesCommonRuleSet"
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
  retention_in_days = 180
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
          label_name = "awswaf:${data.aws_caller_identity.current.account_id}:webacl:${var.stack_description}-cf-uaa-waf-core:${var.waf_label_host_0}"
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

data "aws_caller_identity" "current" {}

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
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
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

  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"

        excluded_rule {
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
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"

        excluded_rule {
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
    priority = 2

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
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "CrossSiteScripting_COOKIE"
        }

        excluded_rule {
          name = "CrossSiteScripting_BODY"
        }

        excluded_rule {
          name = "EC2MetaDataSSRF_BODY"
        }

        excluded_rule {
          name = "EC2MetaDataSSRF_QUERYARGUMENTS"
        }

        excluded_rule {
          name = "GenericLFI_BODY"
        }

        excluded_rule {
          name = "GenericRFI_BODY"
        }

        excluded_rule {
          name = "GenericRFI_QUERYARGUMENTS"
        }

        excluded_rule {
          name = "NoUserAgent_HEADER"
        }

        excluded_rule {
          name = "SizeRestrictions_BODY"
        }

        excluded_rule {
          name = "SizeRestrictions_Cookie_HEADER"
        }

        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
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
    priority = 4

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
    priority = 5
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

// create the cloudwatch log group to log traffic and set cloudwatch retention to 6 months

resource "aws_cloudwatch_log_group" "cf_uaa_waf_core" {
  name = "aws-waf-logs-${var.stack_description}"
  arn = aws_cloudwatch.cf_uaa.arn
  retention_in_days = 180
  tags = {
    Environment = "${var.stack_description}"
  }
}

// create default logging ruleset which is log all and associate to the correct cloudwatch log group

resource "aws_wafv2_web_acl_logging_configuration" "cf_uaa_waf_core" {
  log_destination_configs = aws_cloudwatch.cf_uaa.arn
  resource_arn            = aws_wafv2_web_acl.cf_uaa_waf_core.arn
}

resource "aws_wafv2_web_acl_association" "cf_uaa_waf_core" {
  resource_arn = aws_lb.cf_uaa.arn
  web_acl_arn  = aws_wafv2_web_acl.cf_uaa_waf_core.arn
}

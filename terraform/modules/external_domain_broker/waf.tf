locals {
  name = "external-domain-broker-${var.stack_description}-rate-limit-rule-group"
}

resource "aws_wafv2_rule_group" "rate_limit_group" {
  name     = local.name
  scope    = var.waf_rule_group_scope
  capacity = 4

  rule {
    name     = "RateLimit-COUNT"
    priority = 0

    action {
      count {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = var.aggregate_key_type
        evaluation_window_sec = var.evaluation_window_sec
        limit                 = var.waf_rate_limit_count_threshold
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit-COUNT"
      sampled_requests_enabled   = true
    }
  }


  rule {
    name     = "RateLimit-CHALLENGE"
    priority = 1

    action {
      challenge {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = var.aggregate_key_type
        evaluation_window_sec = var.evaluation_window_sec
        limit                 = var.waf_rate_limit_challenge_threshold
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit-CHALLENGE"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl" "cf_waf_core" {
  name        = "${var.stack_description}-cf_waf_core_acl"
  description = "WebACL with managed core ruleset"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet-rule-1"
    priority = "1"

    override_action = "none"

    visibility_config = {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWSManagedRulesCommonRuleSet-metric"
      sampled_requests_enabled   = false
      }

      managed_rule_group_statement = {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
        }
      }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

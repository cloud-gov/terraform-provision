resource "aws_wafv2_regex_pattern_set" "jndi_regex" {
  name        = "${var.stack_description}-waf-jndi-regex"
  description = "Regex Pattern Set for JNDI"
  scope       = "REGIONAL"

  dynamic "regular_expression" {
    for_each = var.waf_regular_expressions
    content {
      regex_string = regular_expression.value
    }
  }
}
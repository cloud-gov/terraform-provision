resource "aws_wafv2_regex_pattern_set" "jndi_regex" {
  name        = "${var.stack_description}-waf-jndi-regex"
  description = "Regex Pattern Set for JNDI"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "/(\/$|\/%24)(\/{|\/%7[bB])jndi(:|\/%3[aA])"
  }
}
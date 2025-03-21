data "aws_iam_policy_document" "compliance_role_policy" {
  statement {
    sid = "cloudgovComplianceRoleAllow"

    actions = [
      "trustedadvisor:RefreshCheck",
      "servicequota:Get*",
      "servicequota:List*",
      "waf:List*",
      "waf:Get*",
      "waf-regional:List*",
      "waf-regional:GetByteMatchSet",
      "waf-regional:GetIPSet",
      "waf-regional:GetRule",
      "waf-regional:GetSampledRequests",
      "waf-regional:GetSizeConstraintSet",
      "waf-regional:GetSqlInjectionMatchSet",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetXssMatchSet",
      "wafv2:CheckCapacity",
      "wafv2:Describe*",
      "wafv2:Get*",
      "wafv2:List*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.compliance_role_policy.json
}

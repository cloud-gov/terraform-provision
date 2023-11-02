/*
It is easier to iterate on CloudWatch dashboards directly in the console than in Terraform.
If you do so, click "Actions > View/edit source", copy the entire source, and replace the
entire object passed into `dashboard_body = jsonencode()` with the source. Then find/replace
references to the environment -- for example, "production" -- with ${var.stack_description}.

As with the entire repo, make sure your editor is configured to format terraform code on save.
*/
resource "aws_cloudwatch_dashboard" "waf_dashboard" {
  dashboard_name = "WAF_${var.stack_description}"
  dashboard_body = jsonencode({
    "widgets" : [
      {
        "height" : 9,
        "width" : 12,
        "y" : 0,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/WAFV2", "AllowedRequests", "Region", "us-gov-west-1", "Rule", "data-gov-logstash", "WebACL", "${var.stack_description}-cf-uaa-waf-core", { "region" : "us-gov-west-1" }],
            ["...", "${var.stack_description}-AWS-AWSManagedRulesAnonymousIpList", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "BlockedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CountedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CaptchaRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "ChallengeRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "AllowedRequests", ".", ".", ".", "${var.stack_description}-AWS-ManagedRulesAmazonIpReputationList", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "BlockedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CountedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CaptchaRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "ChallengeRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "AllowedRequests", ".", ".", ".", "${var.stack_description}-AWS-KnownBadInputsRuleSet", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "BlockedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CountedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CaptchaRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "ChallengeRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "AllowedRequests", ".", ".", ".", "${var.stack_description}-AWS-AWSManagedRulesCommonRuleSet", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "BlockedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CountedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CaptchaRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "ChallengeRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "BlockedRequests", ".", ".", ".", "BlockMaliciousFingerprints", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "CountedRequests", ".", ".", ".", "CountAPIDataGovRequests", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "ChallengeRequests", ".", ".", ".", "RateLimitBySourceIP-Mboyd-test", ".", ".", { "region" : "us-gov-west-1" }],
            ["...", "RateLimitByForwardedIP-Mboyd-test", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "BlockedRequests", ".", ".", ".", "${var.stack_description}-RateLimitNonCDN", ".", ".", { "region" : "us-gov-west-1" }],
            ["...", "${var.stack_description}-AWS-AWSManagedRulesCommonRuleSet", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "AllowedRequests", ".", ".", ".", "ALL", ".", ".", { "region" : "us-gov-west-1", "visible" : false }],
            [".", "BlockedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1", "visible" : false }],
            [".", "CountedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1", "visible" : false }],
            [".", "CaptchaRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1", "visible" : false }],
            [".", "ChallengeRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1", "visible" : false }],
            [".", "AllowedRequests", ".", ".", ".", "${var.stack_description}-cf-uaa-waf-core-metric", ".", ".", { "region" : "us-gov-west-1" }]
          ],
          "stat" : "Sum",
          "view" : "timeSeries",
          "stacked" : true,
          "period" : 300,
          "region" : "us-gov-west-1",
          "title" : "WAF: Requests by Rule and Action",
          "yAxis" : {
            "left" : {
              "showUnits" : false
            },
            "right" : {
              "showUnits" : false
            }
          }
        }
      },
      {
        "height" : 9,
        "width" : 6,
        "y" : 9,
        "x" : 0,
        "type" : "log",
        "properties" : {
          "query" : "SOURCE 'aws-waf-logs-${var.stack_description}' | stats count(*) as requestCount by httpRequest.clientIp\n| sort requestCount desc\n| limit 100",
          "region" : "us-gov-west-1",
          "stacked" : false,
          "title" : "Top 100 Source IPs by Request Count",
          "view" : "table"
        }
      },
      {
        "height" : 9,
        "width" : 12,
        "y" : 0,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/WAFV2", "AllowedRequests", "WebACL", "${var.stack_description}-cf-uaa-waf-core", "Region", "us-gov-west-1", "Rule", "ALL", { "region" : "us-gov-west-1" }],
            [".", "CountedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "ChallengeRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "RequestsWithValidChallengeToken", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }],
            [".", "BlockedRequests", ".", ".", ".", ".", ".", ".", { "region" : "us-gov-west-1" }]
          ],
          "stat" : "Sum",
          "view" : "timeSeries",
          "stacked" : true,
          "period" : 300,
          "region" : "us-gov-west-1",
          "title" : "WAF Summary: Count of Requests by Action",
          "yAxis" : {
            "left" : {
              "showUnits" : false
            },
            "right" : {
              "showUnits" : false
            }
          }
        }
      },
      {
        "height" : 9,
        "width" : 8,
        "y" : 9,
        "x" : 6,
        "type" : "log",
        "properties" : {
          "query" : "SOURCE 'aws-waf-logs-${var.stack_description}' | fields @timestamp, @message, action\n| parse @message /(?i)\"name\":\"[Hh]ost\",\"value\":\"(?<host>[^\"]+)/\n| stats count() as count group by host, action\n| sort count desc\n| limit 20",
          "region" : "us-gov-west-1",
          "stacked" : false,
          "view" : "table",
          "title" : "Top 20 Target Hosts by Request Count and WAF Action"
        }
      }
    ]
  })
}

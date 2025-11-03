locals {
  bounce_alarm_description = <<EOT
  If the bounce rate reaches 5%, AWS places the account under review. At 10%, AWS pauses the ability for SES to send email from this account.

  See https://docs.aws.amazon.com/ses/latest/dg/reputationdashboardmessages.html#reputationdashboard-bounce for more details.
  EOT

  complaint_alarm_description = <<EOT
  An AWS account is placed under review if its complaint rate is ≥0.1%. Sending is automatically paused if its complaint rate is ≥0.5%.

  See https://docs.aws.amazon.com/ses/latest/dg/reputationdashboardmessages.html#reputationdashboard-complaint for more details.
  EOT
}

locals {
  # Notify the Cloud.gov Platform team and the customer.
  reputation_notification_topics = [
    var.cg_platform_notifications_arn,
    var.cg_platform_slack_notifications_arn
  ]
}

/*
An AWS account is placed under review if its bounce rate is ≥5%. Sending is automatically paused if its bounce rate is ≥10%. For each individual identity, we send a warning alarm at 40% of the review threshold and a critical alarm at 80% of the review threshold. This provides early warning and margin for error.

https://docs.aws.amazon.com/ses/latest/dg/reputationdashboardmessages.html#reputationdashboard-bounce
*/

# 5% * 40% = 2%. 5% * 80% = 4%.
resource "aws_cloudwatch_metric_alarm" "ses_bounce_rate_warning" {
  alarm_name = "${var.resource_prefix}-BounceRate-Warning"
  # Note that alarm_description must be <=1024 chars
  alarm_description = <<EOT
  Warning: The bounce rate for this SES identity has exceeded 2%.

  ${local.bounce_alarm_description}
  EOT

  metric_query {
    id = "m1"
    metric {
      metric_name = "BounceRate"
      namespace   = "AWS/SES"
      period      = 300
      stat        = "Average"
      dimensions = {
        "ConfigurationSetName" = aws_sesv2_configuration_set.email_domain_identity_config.configuration_set_name
      }
    }
    return_data = false
  }

  metric_query {
    id          = "warning_e1"
    expression  = "IF(m1 >= 0.02 && m1 < 0.04, 1, 0)"
    label       = "BounceRateBetween1and5"
    return_data = true
  }

  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = 1
  evaluation_periods        = 1
  alarm_actions             = local.reputation_notification_topics
  ok_actions                = local.reputation_notification_topics
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "ses_bounce_rate_critical" {
  alarm_name = "${var.resource_prefix}-BounceRate-Critical"
  # Note that alarm_description must be <=1024 chars
  alarm_description = <<EOT
  Critical: The bounce rate for this SES identity has exceeded 4%.

  ${local.bounce_alarm_description}
  EOT

  metric_query {
    id = "m1"
    metric {
      metric_name = "BounceRate"
      namespace   = "AWS/SES"
      period      = 300
      stat        = "Average"
      dimensions = {
        "ConfigurationSetName" = aws_sesv2_configuration_set.email_domain_identity_config.configuration_set_name
      }
    }
    return_data = false
  }

  metric_query {
    id          = "critical_e1"
    expression  = "IF(m1 >= 0.04, 1, 0)"
    label       = "BounceRateAbove5"
    return_data = true
  }

  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = 1
  evaluation_periods        = 1
  alarm_actions             = local.reputation_notification_topics
  ok_actions                = local.reputation_notification_topics
  insufficient_data_actions = []
}

/*
An AWS account is placed under review if its complaint rate is ≥0.1%. Sending is automatically paused if its complaint rate is ≥0.5%. For each individual identity, we send a warning alarm at 40% of the review threshold and a critical alarm at 80% of the review threshold. This provides early warning and margin for error.

https://docs.aws.amazon.com/ses/latest/dg/reputationdashboardmessages.html#reputationdashboard-complaint
*/

# 0.1% * 40% = 0.04%. 0.01% * 80% = 0.08%.
resource "aws_cloudwatch_metric_alarm" "ses_complaint_rate_warning" {
  alarm_name = "${var.resource_prefix}-ComplaintRate-Warning"
  # Note that alarm_description must be <=1024 chars
  alarm_description = <<EOT
  Warning: The complaint rate for this SES identity has exceeded 0.04%.

  ${local.complaint_alarm_description}
  EOT

  metric_query {
    id = "m1"
    metric {
      metric_name = "ComplaintRate"
      namespace   = "AWS/SES"
      period      = 300
      stat        = "Average"
      dimensions = {
        "ConfigurationSetName" = aws_sesv2_configuration_set.email_domain_identity_config.configuration_set_name
      }
    }
    return_data = false
  }

  metric_query {
    id          = "warning_e1"
    expression  = "IF(m1 >= 0.0004 && m1 < 0.0008, 1, 0)"
    label       = "ComplaintRateBetween0.02and0.08"
    return_data = true
  }

  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = 1
  evaluation_periods        = 1
  alarm_actions             = local.reputation_notification_topics
  ok_actions                = local.reputation_notification_topics
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "ses_complaint_rate_critical" {
  alarm_name = "${var.resource_prefix}-ComplaintRate-Critical"
  # Note that alarm_description must be <=1024 chars
  alarm_description = <<EOT
  Critical: The complaint rate for this SES identity has exceeded 0.08%.

  ${local.complaint_alarm_description}
  EOT

  metric_query {
    id = "m1"
    metric {
      metric_name = "ComplaintRate"
      namespace   = "AWS/SES"
      period      = 300
      stat        = "Average"
      dimensions = {
        "ConfigurationSetName" = aws_sesv2_configuration_set.email_domain_identity_config.configuration_set_name
      }
    }
    return_data = false
  }

  metric_query {
    id          = "critical_e1"
    expression  = "IF(m1 >= 0.0008, 1, 0)"
    label       = "ComplaintRateAbove0.08"
    return_data = true
  }

  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = 1
  evaluation_periods        = 1
  alarm_actions             = local.reputation_notification_topics
  ok_actions                = local.reputation_notification_topics
  insufficient_data_actions = []
}

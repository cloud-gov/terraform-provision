resource "aws_cloudwatch_metric_alarm" "lb_4XX_anomaly_detection" {
  alarm_name                = "${var.stack_description} CF Load Balancer High 4XX Response Rate"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = 5
  datapoints_to_alarm       = 3
  threshold_metric_id       = "ad1"
  alarm_description         = "Alerts when the targets are returning a higher than normal rate of 4XX responses"
  insufficient_data_actions = []
  actions_enabled           = true
  ok_actions                = []
  alarm_actions             = [var.cg_platform_notifications_arn]
  treat_missing_data        = "missing"

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 20)"
    label       = "HTTPCode_Target_4XX_Count (expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "HTTPCode_Target_4XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.load_balancer_dns
      }
    }
  }

}

resource "aws_cloudwatch_metric_alarm" "load_balancer_request_spike" {
  alarm_name                = "${var.stack_description} Load Balancer Spike in Requests"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  threshold_metric_id       = "e1"
  alarm_description         = "There has been a large spike in load balancer requests to the ${var.stack_description} cloudfoundry apps loadbalancer"
  insufficient_data_actions = []
  actions_enabled           = var.stack_description == "production" ? true : false
  ok_actions                = []
  alarm_actions             = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  treat_missing_data        = "missing"

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 10)"
    label       = "Load_Balancer_Count (expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.load_balancer_dns
      }
    }
  }

}

/*
An AWS account is placed under review if its SES bounce rate is ≥5%. Sending is automatically paused if its bounce rate is ≥10%. To avoid these outcomes, we send a warning alarm at 40% of the review threshold and a critical alarm at 80% of the review threshold. This provides early warning and margin for error.

https://docs.aws.amazon.com/ses/latest/dg/reputationdashboardmessages.html#reputationdashboard-bounce
*/

# 5% * 40% = 2%. 5% * 80% = 4%.
resource "aws_cloudwatch_metric_alarm" "ses_bounce_rate_warning" {
  alarm_name        = "SES-BounceRate-Warning-AccountWide"
  alarm_description = "Warning: The bounce rate for this AWS account has exceeded 2%. The Platform team should take action so AWS does not pause our ability to send email. Runbook link: https://github.com/cloud-gov/internal-docs/blob/main/docs/runbooks/Brokered-Services/AWS-SES.md"

  metric_query {
    id = "m1"
    metric {
      metric_name = "BounceRate"
      namespace   = "AWS/SES"
      period      = 300
      stat        = "Average"
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
  alarm_actions             = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  ok_actions                = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "ses_bounce_rate_critical" {
  alarm_name        = "SES-BounceRate-Critical-AccountWide"
  alarm_description = "Critical: The bounce rate for this AWS account has exceeded 4%. The Platform team must take immediate action so AWS does not pause our ability to send email. Runbook link: https://github.com/cloud-gov/internal-docs/blob/main/docs/runbooks/Brokered-Services/AWS-SES.md"

  metric_query {
    id = "m1"
    metric {
      metric_name = "BounceRate"
      namespace   = "AWS/SES"
      period      = 300
      stat        = "Average"
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
  alarm_actions             = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  ok_actions                = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  insufficient_data_actions = []
}

/*
An AWS account is placed under review if its complaint rate is ≥0.1%. Sending is automatically paused if its complaint rate is ≥0.5%. For each individual identity, we send a warning alarm at 40% of the review threshold and a critical alarm at 80% of the review threshold. This provides early warning and margin for error.

https://docs.aws.amazon.com/ses/latest/dg/reputationdashboardmessages.html#reputationdashboard-complaint
*/

# 0.1% * 40% = 0.04%. 0.01% * 80% = 0.08%.
resource "aws_cloudwatch_metric_alarm" "ses_complaint_rate_warning" {
  alarm_name        = "SES-ComplaintRate-Warning-AccountWide"
  alarm_description = "Warning: The complaint rate for this AWS account has exceeded 0.04%. The Platform team should take action so AWS does not pause our ability to send email. Runbook link: https://github.com/cloud-gov/internal-docs/blob/main/docs/runbooks/Brokered-Services/AWS-SES.md"

  metric_query {
    id = "m1"
    metric {
      metric_name = "ComplaintRate"
      namespace   = "AWS/SES"
      period      = 300
      stat        = "Average"
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
  alarm_actions             = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  ok_actions                = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "ses_complaint_rate_critical" {
  alarm_name        = "SES-ComplaintRate-Critical-AccountWide"
  alarm_description = "Critical: The complaint rate for this AWS account has exceeded 0.08%. The Platform team must take immediate action so AWS does not pause our ability to send email. Runbook link: https://github.com/cloud-gov/internal-docs/blob/main/docs/runbooks/Brokered-Services/AWS-SES.md"

  metric_query {
    id = "m1"
    metric {
      metric_name = "ComplaintRate"
      namespace   = "AWS/SES"
      period      = 300
      stat        = "Average"
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
  alarm_actions             = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  ok_actions                = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  insufficient_data_actions = []
}

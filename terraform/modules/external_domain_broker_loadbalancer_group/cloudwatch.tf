resource "aws_cloudwatch_metric_alarm" "lb_4XX_anomaly_detection" {
  count = var.domains_lbgroup_count

  alarm_name          = "${aws_lb.domains_lbgroup[count.index].arn_suffix}-anomalous-4xx-error-rate"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  threshold_metric_id = "ad1"
  alarm_description   = "Alerts when the targets are returning a higher than normal rate of 4XX responses"
  actions_enabled     = false
  treat_missing_data  = "missing"

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
        LoadBalancer = aws_lb.domains_lbgroup[count.index].arn_suffix
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "lb_4XX_minimum_threshold" {
  count = var.domains_lbgroup_count

  alarm_name          = "${aws_lb.domains_lbgroup[count.index].arn_suffix}-minimum-4xx-error-threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  alarm_description   = "Alerts when the targets are returning more than a minimum threshold of 4XX responses"
  actions_enabled     = false
  treat_missing_data  = "missing"
  threshold           = 100 # only alarm when there are > 100 4xx errors
  period              = 60
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Maximum"

  dimensions = {
    LoadBalancer = aws_lb.domains_lbgroup[count.index].arn_suffix
  }
}

resource "aws_cloudwatch_composite_alarm" "lb_4xx_composite_alarm" {
  count = var.domains_lbgroup_count

  alarm_description = "Alerts when the targets have a higher than expected rate of 4xx errors"
  alarm_name        = "${aws_lb.domains_lbgroup[count.index].arn_suffix}-high-4xx-error-rate"

  alarm_actions = [var.notifications_arn]

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.lb_4XX_anomaly_detection[count.index].alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.lb_4XX_minimum_threshold[count.index].alarm_name})"
}

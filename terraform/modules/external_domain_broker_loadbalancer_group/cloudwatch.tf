resource "aws_cloudwatch_metric_alarm" "lb_4XX_anomaly_detection" {
  count = var.domains_lbgroup_count

  alarm_name                = "${aws_lb.domains_lbgroup[count.index].arn_suffix} - Load Balancer High 4XX Response Rate"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  datapoints_to_alarm       = 3
  threshold_metric_id       = "check"
  alarm_description         = "Alerts when the targets return high 4XX responses, above normal levels and over 100"
  insufficient_data_actions = []
  actions_enabled           = true
  ok_actions                = []
  alarm_actions             = [var.notifications_arn]
  treat_missing_data        = "missing"

  metric_query {
    id          = "m1"
    return_data = false
    metric {
      metric_name = "HTTPCode_Target_4XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = aws_lb.domains_lbgroup[count.index].arn_suffix
      }
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 20)"
    label       = "Anomaly Band"
    return_data = false
  }

  metric_query {
    id          = "above_threshold"
    expression  = "m1 > 100"
    label       = "m1 > 100"
    return_data = false
  }

  metric_query {
    id          = "anomaly_violation"
    expression  = "m1 > ad1"
    label       = "Anomaly Violation"
    return_data = false
  }

  metric_query {
    id          = "check"
    expression  = "IF(above_threshold AND anomaly_violation, 1, 0)"
    label       = "Alert if 4XX > 100 and anomalous"
    return_data = true
  }
}

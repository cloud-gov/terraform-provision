resource "aws_cloudwatch_metric_alarm" "lb_4XX_anomaly_detection" {
  count = var.domains_lbgroup_count

  alarm_name                = "${aws_lb.domains_lbgroup[count.index].arn_suffix} - Load Balancer High 4XX Response Rate"
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
        LoadBalancer = aws_lb.domains_lbgroup[count.index].arn_suffix
      }
    }
  }
}

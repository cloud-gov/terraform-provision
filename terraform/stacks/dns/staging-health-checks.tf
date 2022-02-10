####################################################
# healthchecks zero-downtime deployment assertions #
####################################################

resource "aws_route53_health_check" "stage_uaa_healthcheck" {
  fqdn              = "uaa.fr-stage.cloud.gov"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
}

resource "aws_route53_health_check" "stage_api_healthcheck" {
  fqdn              = "api.fr-stage.cloud.gov"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
}

resource "aws_route53_health_check" "stage_app_healthcheck" {
  fqdn              = "test-python-flask.fr-stage.cloud.gov"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
}

resource "aws_route53_health_check" "stage_aggregate_health" {
  type                   = "CALCULATED"
  child_health_threshold = 3
  child_healthchecks     = [aws_route53_health_check.stage_api_healthcheck.id, aws_route53_health_check.stage_app_healthcheck.id, aws_route53_health_check.stage_uaa_healthcheck.id]
}

output "staging_aggregate_healthcheck_id" {
  value = aws_route53_health_check.stage_aggregate_health.id
}

####################
# end healthchecks #
####################

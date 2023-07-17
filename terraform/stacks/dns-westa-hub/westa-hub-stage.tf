resource "aws_route53_zone" "staging_zone" {
  name = "westa-stage.cloud.gov"
}

#resource "aws_route53_record" "staging_ns" {
#  zone_id = aws_route53_zone.staging_zone.zone_id
#  name    = "westa-stage.cloud.gov."
#  type    = "NS"
#  ttl     = "30"
#  records = aws_route53_zone.staging_zone.name_servers
#}


resource "aws_route53_record" "cloud_gov_prometheus_stage_cloud_gov_a" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "prometheus.westa-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_prometheus_stage_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "prometheus.westa-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_alertmanager_stage_cloud_gov_a" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "alertmanager.westa-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_alertmanager_stage_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "alertmanager.westa-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_grafana_stage_cloud_gov_a" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "grafana.westa-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_grafana_stage_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "grafana.westa-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_doomsday_stage_cloud_gov_a" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "doomsday.westa-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_doomsday_stage_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "doomsday.westa-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ci_stage_cloud_gov_a" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "ci.westa-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ci_stage_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "ci.westa-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_credhub_stage_cloud_gov_a" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "credhub.westa-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_credhub_stage_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.staging_zone.zone_id
  name    = "credhub.westa-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "cloud_gov_zone" {
  name = "westa.cloud.gov"
}

#resource "aws_route53_record" "westa_ns" {
#  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
#  name    = "westa.cloud.gov."
#  type    = "NS"
#  ttl     = "30"
#  records = aws_route53_zone.cloud_gov_zone.name_servers
#}

resource "aws_route53_record" "cloud_gov_ci_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "ci.westa.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ci_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "ci.westa.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_credhub_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "credhub.westa.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_credhub_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "credhub.westa.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_prometheus_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "prometheus.westa.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_prometheus_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "prometheus.westa.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_alertmanager_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "alertmanager.westa.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_alertmanager_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "alertmanager.westa.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_grafana_westa_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "grafana.westa.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_grafana_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "grafana.westa.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_doomsday_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "doomsday.westa.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_doomsday_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "doomsday.westa.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_nessus_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "nessus.westa.cloud.gov."
  type    = "CNAME"
  ttl     = 300

  records = [
    "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}",
  ]
}

resource "aws_route53_record" "cloud_gov_ops_uaa_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "opsuaa.westa.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.opsuaa_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ops_login_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "opslogin.westa.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.opsuaa_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

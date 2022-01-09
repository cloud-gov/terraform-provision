
data "terraform_remote_state" "tooling" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.tooling_stack_name}/terraform.tfstate"
  }
}

resource "aws_route53_record" "ci_a" {
  zone_id = var.zone_id
  name    = "ci.${var.subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ci_aaaa" {
  zone_id = var.zone_id
  name    = "ci.${var.subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "credhub_a" {
  zone_id = var.zone_id
  name    = "credhub.${var.subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "credhub_aaaa" {
  zone_id = var.zone_id
  name    = "credhub.${var.subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "prometheus_a" {
  zone_id = var.zone_id
  name    = "prometheus.${var.subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "prometheus_aaaa" {
  zone_id = var.zone_id
  name    = "prometheus.${var.subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alertmanager_a" {
  zone_id = var.zone_id
  name    = "alertmanager.${var.subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alertmanager_aaaa" {
  zone_id = var.zone_id
  name    = "alertmanager.${var.subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "grafana_a" {
  zone_id = var.zone_id
  name    = "grafana.${var.subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "grafana_aaaa" {
  zone_id = var.zone_id
  name    = "grafana.${var.subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "doomsday_a" {
  zone_id = var.zone_id
  name    = "doomsday.${var.subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "doomsday_aaaa" {
  zone_id = var.zone_id
  name    = "doomsday.${var.subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "nessus_a" {
  zone_id = var.zone_id
  name    = "nessus.${var.subdomain}."
  type    = "CNAME"
  ttl     = 300

  records = [
    "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}",
  ]
}

resource "aws_route53_record" "opsuaa_a" {
  zone_id = var.zone_id
  name    = "opsuaa.${var.subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.opsuaa_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "opsuaa_aaaa" {
  zone_id = var.zone_id
  name    = "opslogin.${var.subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.opsuaa_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
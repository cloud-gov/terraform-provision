#TODO: this is just a stub, still need to work through getting the new tooling/hub state imported

variable "subdomain" {
    default = "fr.cloud.gov"
}

variable "zone_id" {
    default = ""
}

variable "alb_zone_id" {
    default = ""
}


resource "aws_route53_record" "prometheus_a" {
  zone_id = var.zone_id
  name    = "prometheus.${subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "prometheus_aaaa" {
  zone_id = var.zone_id
  name    = "prometheus.${subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alertmanager_a" {
  zone_id = var.zone_id
  name    = "alertmanager.${subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alertmanager_aaaa" {
  zone_id = var.zone_id
  name    = "alertmanager.${subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "grafana_a" {
  zone_id = var.zone_id
  name    = "grafana.${subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "grafana_aaaa" {
  zone_id = var.zone_id
  name    = "grafana.${subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "doomsday_a" {
  zone_id = var.zone_id
  name    = "doomsday.${subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "doomsday_aaaa" {
  zone_id = var.zone_id
  name    = "doomsday.${subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ci_a" {
  zone_id = var.zone_id
  name    = "ci.${subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ci_aaaa" {
  zone_id = var.zone_id
  name    = "ci.${subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "credhub_a" {
  zone_id = var.zone_id
  name    = "credhub.${subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "credhub_aaaa" {
  zone_id = var.zone_id
  name    = "credhub.${subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

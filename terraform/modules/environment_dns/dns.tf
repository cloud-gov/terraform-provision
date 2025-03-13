data "terraform_remote_state" "stack" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.stack_name}/terraform.tfstate"
  }
}

resource "aws_route53_record" "star_admin_a" {
  zone_id = var.zone_id
  name    = "*.${var.admin_subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "star_admin_aaaa" {
  zone_id = var.zone_id
  name    = "*.${var.admin_subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "star_app_a" {
  zone_id = var.zone_id
  name    = "*.${var.app_subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "star_app_aaaa" {
  zone_id = var.zone_id
  name    = "*.${var.app_subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "uaa_a" {
  zone_id = var.zone_id
  name    = "uaa.${var.admin_subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "uaa_aaaa" {
  zone_id = var.zone_id
  name    = "uaa.${var.admin_subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "login_a" {
  zone_id = var.zone_id
  name    = "login.${var.admin_subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "login_aaaa" {
  zone_id = var.zone_id
  name    = "login.${var.admin_subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "logs_platform_a" {
  zone_id = var.zone_id
  name    = "logs-platform.${var.admin_subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "logs_platform_aaaa" {
  zone_id = var.zone_id
  name    = "logs-platform.${var.admin_subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "idp_a" {
  zone_id = var.zone_id
  name    = "idp.${var.admin_subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "idp_aaaa" {
  zone_id = var.zone_id
  name    = "idp.${var.admin_subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.main_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "ssh_a" {
  zone_id = var.zone_id
  name    = "ssh.${var.admin_subdomain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.diego_elb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ssh_aaaa" {
  zone_id = var.zone_id
  name    = "ssh.${var.admin_subdomain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.diego_elb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "tcp_a" {
  for_each = toset(data.terraform_remote_state.stack.outputs.tcp_lb_dns_names)
  zone_id  = var.zone_id
  name     = "tcp-${index(data.terraform_remote_state.stack.outputs.tcp_lb_dns_names, each.key)}.${var.domain}"
  type     = "A"
  alias {
    name                   = each.key
    zone_id                = var.nlb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "tcp_aaaa" {
  for_each = toset(data.terraform_remote_state.stack.outputs.tcp_lb_dns_names)
  zone_id  = var.zone_id
  name     = "tcp-${index(data.terraform_remote_state.stack.outputs.tcp_lb_dns_names, each.key)}.${var.domain}"
  type     = "AAAA"
  alias {
    name                   = each.key
    zone_id                = var.nlb_zone_id
    evaluate_target_health = false
  }
}

locals {
  brokered_mail_subdomain = "appmail.${var.domain}"
}

resource "aws_route53_zone" "brokered_mail_zone" {
  name    = local.brokered_mail_subdomain
  comment = "If customers create a brokered SES identity but do not specify a domain, a subdomain will be created for them in this zone. This allows sending mail for testing purposes."
}

data "aws_route53_zone" "apex_domain" {
  name = var.domain
}

resource "aws_route53_record" "brokered_mail_ns" {
  zone_id = data.aws_route53_zone.apex_domain.zone_id
  name    = local.brokered_mail_subdomain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.brokered_mail_zone.name_servers
}

locals {
  external_domain               = "external-domains-${var.stack_name}.cloud.gov"
  csb_helper_domain_name        = "services.${var.domain}."
  csb_helper_domain_record      = "services.${var.domain}.${local.external_domain}"
  csb_helper_acme_domain_name   = "_acme-challenge.services.${var.domain}."
  csb_helper_acme_domain_record = "_acme-challenge.services.${var.domain}.${local.external_domain}"
}

// DNS records corresponding to the External Domain Service Instance
// provisioned for the Cloud Service Broker documentation proxy.
// Repo: https://github.com/cloud-gov/csb
// External domain reference: https://cloud.gov/docs/services/external-domain-service/
resource "aws_route53_record" "csb_helper_acme_challenge" {
  name    = local.csb_helper_acme_domain_name
  type    = "CNAME"
  zone_id = var.zone_id
  ttl     = 300

  records = [local.csb_helper_acme_domain_record]
}

resource "aws_route53_record" "csb_helper_domain" {
  name    = local.csb_helper_domain_name
  type    = "CNAME"
  zone_id = var.zone_id
  ttl     = 300

  records = [local.csb_helper_domain_record]

}

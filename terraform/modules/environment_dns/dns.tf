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


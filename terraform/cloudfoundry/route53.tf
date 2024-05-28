variable "alb_zone_id" {
  default = "Z33AYJ8TM3BH4J" # this is for us-gov-west-1. See others here: https://docs.aws.amazon.com/general/latest/gr/elb.html
}

variable "nlb_zone_id" {
  default = "ZMG1MZ2THAWF1" # this is for us-gov-west-1. See others here: https://docs.aws.amazon.com/general/latest/gr/elb.html
}

variable domain {
  type = string
  description = "The root domain of the Cloud Foundry installation. The api and apps subdomains will be created using this domain. Example: westa.cloud.gov"
}

variable environment {
  type = string
  description = "The enviroment name. Example: westa"
}

variable remote_state_bucket {
  type = string 
}

variable remote_state_region {
  type = string
}

data "terraform_remote_state" "stack" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.environment}-hub/terraform.tfstate"
  }
}

resource "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "ns" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.zone.name_servers
}

resource "aws_route53_record" "api_a" {
  zone_id = aws_route53_zone.zone.id
  name    = "api.${var.domain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "api_aaaa" {
  zone_id = aws_route53_zone.zone.id
  name    = "api.${var.domain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "star_apps_a" {
  zone_id = aws_route53_zone.zone.id
  name    = "*.apps.${var.domain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "star_apps_aaaa" {
  zone_id = aws_route53_zone.zone.id
  name    = "*.apps.${var.domain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "uaa_a" {
  zone_id = aws_route53_zone.zone.id
  name    = "uaa.${var.domain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "uaa_aaaa" {
  zone_id = aws_route53_zone.zone.id
  name    = "uaa.${var.domain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "login_a" {
  zone_id = aws_route53_zone.zone.id
  name    = "login.${var.domain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "login_aaaa" {
  zone_id = aws_route53_zone.zone.id
  name    = "login.${var.domain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ssh_a" {
  zone_id = aws_route53_zone.zone.id
  name    = "ssh.${var.domain}."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.diego_elb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ssh_aaaa" {
  zone_id = aws_route53_zone.zone.id
  name    = "ssh.${var.domain}."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.stack.outputs.diego_elb_dns_name}"
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "tcp_a" {
  for_each = toset(data.terraform_remote_state.stack.outputs.tcp_lb_dns_names)
  zone_id  = aws_route53_zone.zone.id
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
  zone_id  = aws_route53_zone.zone.id
  name     = "tcp-${index(data.terraform_remote_state.stack.outputs.tcp_lb_dns_names, each.key)}.${var.domain}"
  type     = "AAAA"
  alias {
    name                   = each.key
    zone_id                = var.nlb_zone_id
    evaluate_target_health = false
  }
}
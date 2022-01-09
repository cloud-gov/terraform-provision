resource "aws_route53_record" "cloud_gov_star_dev_env_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.cf_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_dev_env_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.cf_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "cloud_gov_uaa_dev_env_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "uaa.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "cloud_gov_uaa_dev_env_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "uaa.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_login_dev_env_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "login.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "cloud_gov_login_dev_env_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "login.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.cf_uaa_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_idp_dev_us_gov_west_1_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "idp.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_idp_dev_us_gov_west_1_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "idp.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ssh_dev_env_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "ssh.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.diego_elb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "cloud_gov_ssh_fr_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "ssh.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.diego_elb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_logs_platform_dev_env_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "logs-platform.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_logs_platform_dev_env_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "logs-platform.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

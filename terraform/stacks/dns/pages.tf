################
## Production ##
################
resource "aws_route53_record" "cloud_gov_pages_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "pages.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"]
}

resource "aws_route53_record" "cloud_gov_star_pages_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.pages.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_pages_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.pages.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_sites_pages_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.sites.pages.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_sites_pages_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.sites.pages.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

## Templates ##

resource "aws_route53_record" "cloud_gov_uswds-11ty_pages_cloud_gov" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "uswds-11ty.pages.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["uswds-11ty.pages.cloud.gov.external-domains-production.cloud.gov."]
}

resource "aws_route53_record" "cloud_gov__acme-challenge_uswds-11ty_pages_cloud_gov" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "_acme-challenge.uswds-11ty.pages.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["_acme-challenge.uswds-11ty.pages.cloud.gov.external-domains-production.cloud.gov."]
}

resource "aws_route53_record" "cloud_gov_uswds-gatsby_pages_cloud_gov" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "uswds-gatsby.pages.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["uswds-gatsby.pages.cloud.gov.external-domains-production.cloud.gov."]
}

resource "aws_route53_record" "cloud_gov__acme-challenge_uswds-gatsby_pages_cloud_gov" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "_acme-challenge.uswds-gatsby.pages.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["_acme-challenge.uswds-gatsby.pages.cloud.gov.external-domains-production.cloud.gov."]
}

resource "aws_route53_record" "cloud_gov_uswds-jekyll_pages_cloud_gov" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "uswds-jekyll.pages.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["uswds-jekyll.pages.cloud.gov.external-domains-production.cloud.gov."]
}

resource "aws_route53_record" "cloud_gov__acme-challenge_uswds-jekyll_pages_cloud_gov" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "_acme-challenge.uswds-jekyll.pages.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["_acme-challenge.uswds-jekyll.pages.cloud.gov.external-domains-production.cloud.gov."]
}

## End Production ##

#############
## Staging ##
#############
resource "aws_route53_record" "cloud_gov_pages_staging_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "pages-staging.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"]
}

resource "aws_route53_record" "cloud_gov_star_pages_staging_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.pages-staging.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_pages_staging_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.pages-staging.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_sites_pages_staging_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.sites.pages-staging.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_sites_pages_staging_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.sites.pages-staging.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
## End Staging ##

#################
## Development ##
#################
resource "aws_route53_record" "cloud_gov_pages_dev_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "pages-dev.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"]
}

resource "aws_route53_record" "cloud_gov_star_pages_dev_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.pages-dev.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_pages_dev_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.pages-dev.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_sites_pages_dev_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.sites.pages-dev.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_sites_pages_dev_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "*.sites.pages-dev.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
## End Development ##

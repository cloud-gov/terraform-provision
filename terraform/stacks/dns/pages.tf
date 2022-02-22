################
## Production ##
################
# resource "aws_route53_record" "cloud_gov_pages_cloud_gov_cname" {
#   zone_id = aws_route53_zone.cloud_gov_zone.zone_id
#   name    = "pages.cloud.gov."
#   type    = "CNAME"
#   ttl     = 60
#   records = ["dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"]
# }

# resource "aws_route53_record" "cloud_gov_star_pages_cloud_gov_a" {
#   zone_id = aws_route53_zone.cloud_gov_zone.zone_id
#   name    = "*.pages.cloud.gov."
#   type    = "A"

#   alias {
#     name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
#     zone_id                = var.cloudfront_zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "cloud_gov_star_pages_cloud_gov_aaaa" {
#   zone_id = aws_route53_zone.cloud_gov_zone.zone_id
#   name    = "*.pages.cloud.gov."
#   type    = "AAAA"

#   alias {
#     name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
#     zone_id                = var.cloudfront_zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "cloud_gov_star_sites_pages_cloud_gov_a" {
#   zone_id = aws_route53_zone.cloud_gov_zone.zone_id
#   name    = "*.sites.pages.cloud.gov."
#   type    = "A"

#   alias {
#     name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
#     zone_id                = var.cloudfront_zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "cloud_gov_star_sites_pages_cloud_gov_aaaa" {
#   zone_id = aws_route53_zone.cloud_gov_zone.zone_id
#   name    = "*.sites.pages.cloud.gov."
#   type    = "AAAA"

#   alias {
#     name                   = "dualstack.${data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name}"
#     zone_id                = var.cloudfront_zone_id
#     evaluate_target_health = false
#   }
# }
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

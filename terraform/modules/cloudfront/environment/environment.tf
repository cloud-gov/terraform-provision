data "terraform_remote_state" "stack" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.stack_description}/terraform.tfstate"
  }
}

# One ACL for all distributions in the environment.
resource "aws_wafv2_web_acl" "commercial_acl" {
  name        = "${var.stack_description}-commercial-acl"
  description = "ACL for use with CloudFront and Shield Advanced."
  scope       = "REGIONAL"

  default_action {
    # no rules needed; they'll be added by Shield Advanced.
    allow {
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_description}-commercial-acl-metric"
    sampled_requests_enabled   = true
  }
}

module "star_admin" {
  source = "../distribution"
  origin = {
    lb_dns_name   = data.terraform_remote_state.stack.outputs.cf_lb_dns_name
    lb_http_port  = 80  # modules/cloudfoundry/elb_main.tf "aws_lb" "cf"
    lb_https_port = 443 # modules/cloudfoundry/elb_main.tf "aws_lb" "cf"
  }
  acl_arn = aws_wafv2_web_acl.commercial_acl.arn
}

# Other LBs to protect after testing one.
# module "star_app" {
#   source = "../distribution"
#   # cf_apps_lb_dns_name
# }

# module "admin_ui" {
#   source = "../distribution"
#   # admin_lb_dns_name
# }

# module "uaa" {
#   source = "../distribution"
#   # cf_uaa_lb_dns_name
# }

# module "login" {
#   source = "../distribution"
#   # cf_uaa_lb_dns_name
# }

# module "logs_platform" {
#   source = "../distribution"
#   # main_lb_dns_name
# }

# module "idp" {
#   source = "../distribution"
#   # main_lb_dns_name
# }

# module "ssh" {
#   source = "../distribution"
#   # diego_elb_dns_name
# }

# module "tcp" {
#   source = "../distribution"
#   # todo, NBLs, probably not needed
# }

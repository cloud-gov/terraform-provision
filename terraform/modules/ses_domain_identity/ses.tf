locals {
  email_domain = "${var.email_identity_subdomain}.${var.environment_domain}"
}

resource "aws_sesv2_email_identity" "email_domain_identity" {
  email_identity         = local.email_domain
  configuration_set_name = aws_sesv2_configuration_set.email_domain_identity_config.configuration_set_name
}

resource "aws_sesv2_email_identity_mail_from_attributes" "email_mail_from" {
  email_identity = "${var.mail_from_domain}.${aws_sesv2_email_identity.email_domain_identity.email_identity}"

  behavior_on_mx_failure = "REJECT_MESSAGE"
  mail_from_domain       = aws_sesv2_email_identity.email_domain_identity.email_identity
}

resource "aws_sesv2_configuration_set" "email_domain_identity_config" {
  configuration_set_name = "${var.email_identity_subdomain}-${var.stack_description}"

  delivery_options {
    tls_policy = "REQUIRE"
  }
  reputation_options {
    reputation_metrics_enabled = true
  }
  suppression_options {
    suppressed_reasons = ["BOUNCE", "COMPLAINT"]
  }
}

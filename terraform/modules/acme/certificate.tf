terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
      version = "~>2.23"
    }
  }
}

locals {
  config  = yamldecode(file("${path.module}/acme.yml"))
}

provider "acme" {
  server_url = locals.config.acme.use_test_endpoint ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = locals.config.acme.registration_email
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = locals.config.acme.common_name
  subject_alternative_names = locals.config.acme.subject_alternative_names

  dns_challenge {
    provider = "route53"
  }
}

resource "aws_iam_server_certificate" "iam_certificate" {
  name             = replace(acme_certificate.certificate.certificate_domain,"\\*","star")
  certificate_body = acme_certificate.certificate.certificate_pem
  private_key      = acme_certificate.certificate.private_key_pem
}

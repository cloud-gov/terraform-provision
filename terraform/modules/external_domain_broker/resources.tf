# These resources are for https://github.com/cloud-gov/external-domain-broker

resource "aws_route53_zone" "zone" {
  name    = "external-domains-${var.stack_description}.cloud.gov"
  comment = "Hosts TXT and CNAME records for the external-domain-broker"
}

data "aws_route53_zone" "cloud_gov" {
  name = "cloud.gov"
}

resource "aws_route53_record" "record" {
  name    = "${aws_route53_zone.zone.name}"
  zone_id = "${data.aws_route53_zone.cloud_gov.zone_id}"
  type    = "NS"
  ttl     = "60"

  records = [
    "${aws_route53_zone.zone.name_servers.0}",
    "${aws_route53_zone.zone.name_servers.1}",
    "${aws_route53_zone.zone.name_servers.2}",
    "${aws_route53_zone.zone.name_servers.3}",
  ]
}

# Used for the acceptance tests
resource "aws_route53_record" "acceptance_test_domain" {
  count   = 2
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "test-${count.index}.${var.stack_description}.edb.cloud.gov"
  type    = "CNAME"
  ttl     = 600
  records = ["test-${count.index}.${var.stack_description}.edb.cloud.gov.${aws_route53_zone.name}."]
}

resource "aws_route53_record" "acceptance_test_acme_challenge" {
  count   = 2
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "_acme-challenge.test-${count.index}.${var.stack_description}.edb.cloud.gov"
  type    = "CNAME"
  ttl     = 600
  records = ["_acme-challenge.test-${count.index}.${var.stack_description}.edb.cloud.gov.${aws_route53_zone.name}."]
}

data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    account_id        = "${var.account_id}"
    hosted_zone_id    = "${aws_route53_zone.zone.zone_id}"
    stack             = "${var.stack_description}"
  }
}

resource "aws_iam_user" "iam_user" {
  name = "external-domain-broker-${var.stack_description}"
}

resource "aws_iam_access_key" "iam_access_key_v3" {
  user = "${aws_iam_user.iam_user.name}"
}

resource "aws_iam_user_policy" "iam_policy" {
  name   = "${aws_iam_user.iam_user.name}-policy"
  user   = "${aws_iam_user.iam_user.name}"
  policy = "${data.template_file.policy.rendered}"
}

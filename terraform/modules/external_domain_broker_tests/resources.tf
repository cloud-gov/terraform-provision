resource "aws_route53_zone" "zone" {
  name    = "${var.stack_description}.edb.cloud.gov"
  comment = "Hosts TXT and CNAME records for the external-domain-broker tests"
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

resource "aws_route53_zone" "stack_test_0" {
  name    = "${var.stack_description}.cloud-gov-test-domain-0.com"
  comment = "Hosts TXT and CNAME records for the external-domain-broker tests"
}

data "aws_route53_zone" "test_0" {
  name = "cloud-gov-test-domain-0.com"
}
resource "aws_route53_record" "record" {
  name    = "${aws_route53_zone.stack_test_0.name}"
  zone_id = "${data.aws_route53_zone.test_0.zone_id}"
  type    = "NS"
  ttl     = "60"

  records = [
    "${aws_route53_zone.stack_test_0.name_servers.0}",
    "${aws_route53_zone.stack_test_0.name_servers.1}",
    "${aws_route53_zone.stack_test_0.name_servers.2}",
    "${aws_route53_zone.stack_test_0.name_servers.3}",
  ]
}

resource "aws_route53_zone" "stack_test_1" {
  name    = "${var.stack_description}.cloud-gov-test-domain-1.com"
  comment = "Hosts TXT and CNAME records for the external-domain-broker tests"
}

data "aws_route53_zone" "test_1" {
  name = "cloud-gov-test-domain-1.com"
}
resource "aws_route53_record" "record" {
  name    = "${aws_route53_zone.stack_test_1.name}"
  zone_id = "${data.aws_route53_zone.test_1.zone_id}"
  type    = "NS"
  ttl     = "60"

  records = [
    "${aws_route53_zone.stack_test_1.name_servers.0}",
    "${aws_route53_zone.stack_test_1.name_servers.1}",
    "${aws_route53_zone.stack_test_1.name_servers.2}",
    "${aws_route53_zone.stack_test_1.name_servers.3}",
  ]
}

resource "aws_route53_zone" "stack_test_2" {
  name    = "${var.stack_description}.cloud-gov-test-domain-2.com"
  comment = "Hosts TXT and CNAME records for the external-domain-broker tests"
}

data "aws_route53_zone" "test_2" {
  name = "cloud-gov-test-domain-2.com"
}
resource "aws_route53_record" "record" {
  name    = "${aws_route53_zone.stack_test_2.name}"
  zone_id = "${data.aws_route53_zone.test_2.zone_id}"
  type    = "NS"
  ttl     = "60"

  records = [
    "${aws_route53_zone.stack_test_2.name_servers.0}",
    "${aws_route53_zone.stack_test_2.name_servers.1}",
    "${aws_route53_zone.stack_test_2.name_servers.2}",
    "${aws_route53_zone.stack_test_2.name_servers.3}",
  ]
}

resource "aws_route53_zone" "stack_test_3" {
  name    = "${var.stack_description}.cloud-gov-test-domain-3.com"
  comment = "Hosts TXT and CNAME records for the external-domain-broker tests"
}

data "aws_route53_zone" "test_3" {
  name = "cloud-gov-test-domain-3.com"
}
resource "aws_route53_record" "record" {
  name    = "${aws_route53_zone.stack_test_3.name}"
  zone_id = "${data.aws_route53_zone.test_3.zone_id}"
  type    = "NS"
  ttl     = "60"

  records = [
    "${aws_route53_zone.stack_test_3.name_servers.0}",
    "${aws_route53_zone.stack_test_3.name_servers.1}",
    "${aws_route53_zone.stack_test_3.name_servers.2}",
    "${aws_route53_zone.stack_test_3.name_servers.3}",
  ]
}

data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    aws_partition = "${var.aws_partition}"
    hosted_zone_0 = "${aws_route53_zone.zone.zone_id}"
    hosted_zone_1 = "${aws_route53_zone.test_0.zone_id}"
    hosted_zone_2 = "${aws_route53_zone.zone_1.zone_id}"
    hosted_zone_3 = "${aws_route53_zone.zone_2.zone_id}"
    hosted_zone_4 = "${aws_route53_zone.zone_3.zone_id}"
  }
}

resource "aws_iam_user" "iam_user" {
  name = "external-domain-broker-tests-${var.stack_description}"
}

resource "aws_iam_access_key" "iam_access_key_v1" {
  user = "${aws_iam_user.iam_user.name}"
}

resource "aws_iam_user_policy" "iam_policy" {
  name = "${aws_iam_user.iam_user.name}-policy"
  user = "${aws_iam_user.iam_user.name}"
  policy = "${data.template_file.policy.rendered}"
}

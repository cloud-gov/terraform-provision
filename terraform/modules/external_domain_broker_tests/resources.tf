resource "aws_route53_zone" "zone" {
  name    = "${var.stack_description}.edb.cloud.gov"
  comment = "Hosts TXT and CNAME records for the external-domain-broker tests"
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
data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    aws_partition = "${var.aws_partition}"
    hosted_zone = "${data.aws_route53_zone.zone.zone_id}"
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

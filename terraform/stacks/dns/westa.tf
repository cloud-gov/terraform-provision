resource "aws_route53_zone" "westa_zone" {
  name = "westa.cloud.gov"
}

resource "aws_route53_record" "westa_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "westa.cloud.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.westa_zone.name_servers
}

resource "aws_route53_zone" "westa_stage_zone" {
  name = "westa-stage.cloud.gov"
}

resource "aws_route53_record" "westa-stage_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "westa-stage.cloud.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.westa_stage_zone.name_servers
}
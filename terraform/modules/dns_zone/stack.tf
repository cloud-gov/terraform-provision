provider aws {
}
provider aws {
  alias = "apex"
}
resource "aws_route53_zone" "self_zone" {
    name = var.domain
}

resource "aws_route53_record" "ns_record" {
  provider  = aws.apex
  zone_id   = var.parent_zone_id
  name      = var.domain
  type      = "NS"
  ttl       = "30"
  records   = aws_route53_zone.self_zone.name_servers
}
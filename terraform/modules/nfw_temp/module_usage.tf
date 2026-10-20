module "central_inspection" {
  source = "./modules/network-firewall-centralized"

  name_prefix        = "prod-inspection"
  availability_zones = ["us-east-1a", "us-east-1b"]

  create_transit_gateway = true
  amazon_side_asn        = 64512

  inspection_vpc_cidr   = "10.100.0.0/16"
  firewall_subnet_cidrs = ["10.100.0.0/28", "10.100.0.16/28"]
  tgw_subnet_cidrs      = ["10.100.1.0/28", "10.100.1.16/28"]
  public_subnet_cidrs   = ["10.100.2.0/28", "10.100.2.16/28"]

  allowed_domains = [".amazonaws.com", ".example.gov"]

  spoke_vpcs = {
    app = {
      vpc_id                    = "vpc-0aaa111"
      tgw_attachment_subnet_ids = ["subnet-app-a", "subnet-app-b"]
      route_table_ids           = ["rtb-app-private-a", "rtb-app-private-b"]
      spoke_cidrs               = ["10.10.0.0/16"]
      inspect_egress            = true
    }
    data = {
      vpc_id                    = "vpc-0bbb222"
      tgw_attachment_subnet_ids = ["subnet-data-a", "subnet-data-b"]
      route_table_ids           = ["rtb-data-private-a", "rtb-data-private-b"]
      spoke_cidrs               = ["10.20.0.0/16"]
      inspect_egress            = true
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

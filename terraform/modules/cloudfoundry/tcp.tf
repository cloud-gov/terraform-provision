module "tcp_platform" {
  count  = var.include_tcp_routes ? 1 : 0
  source = "./tcp"

  elb_subnets          = var.elb_subnets
  stack_description    = var.stack_description
  tcp_allow_cidrs_ipv4 = var.tcp_allow_cidrs_ipv4
  tcp_allow_cidrs_ipv6 = var.tcp_allow_cidrs_ipv6
  tcp_first_port       = 10000
  vpc_id               = var.vpc_id

  tags = {
    Stack    = var.stack_description
    Customer = "cloud-gov"
    Usage    = "internal"
  }
}

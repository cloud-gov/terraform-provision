resource "aws_vpc_endpoint" "private-s3" {
  vpc_id          = aws_vpc.main_vpc.id
  service_name    = "com.amazonaws.${var.aws_default_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.az1_private_route_table.id, aws_route_table.az2_private_route_table.id]
  policy          = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PrivateS3Access",
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": "*",
        "Principal": "*",
        "Condition": {
          "ForAllValues:StringEquals": {
            "aws:PrincipalAccount": ${jsonencode(local.policy_account_list)},
            "aws:ResourceAccount": ${jsonencode(local.policy_account_list)}
          }				
        }        
    },
    {
      "Sid": "Access-to-ecr-buckets",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::prod-us-gov-west-1-starport-layer-bucket/*",
        "arn:aws:s3:::prod-us-gov-east-1-starport-layer-bucket/*",
        "arn:aws:s3:::prod-us-east-1-starport-layer-bucket/*"
      ]
    }
  ]
}
EOF

}

resource "aws_vpc_endpoint" "customer_s3" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.${var.aws_default_region}.s3"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.bosh.id]
  subnet_ids          = [aws_subnet.az1_public.id, aws_subnet.az2_public.id]
}

data "aws_network_interface" "vpce_customer_s3_if1"{
  id = local.network_interface_ids[0]
}

data "aws_network_interface" "vpce_customer_s3_if2"{
  id = local.network_interface_ids[1] 
}

data "aws_caller_identity" "current" {}

locals {
  network_interface_ids = tolist(aws_vpc_endpoint.customer_s3.network_interface_ids)
  policy_account_list = concat(var.s3_gateway_policy_accounts, [data.aws_caller_identity.current.account_id])
}

resource "aws_vpc_endpoint" "private-s3" {
  vpc_id          = aws_vpc.main_vpc.id
  service_name    = "com.amazonaws.${var.aws_default_region}.s3"
  route_table_ids = [aws_route_table.az1_private_route_table.id, aws_route_table.az2_private_route_table.id]
  policy          = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "PrivateS3Access",
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": "*",
        "Principal": "*"
        "Condition": {
          "ForAllValues:StringEquals": {
            "aws:PrincipalAccount": ${account_id},
            "aws:ResourceAccount": ${account_id}"
          }				
        }        
    }]
}
EOF

}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

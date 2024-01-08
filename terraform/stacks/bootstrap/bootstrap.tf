terraform {
  backend "s3" {
  }
}

data "aws_availability_zones" "available" {
}

variable "ingress_cidrs" {
  type    = list(string)
  default = ["159.142.0.0/16"]
}

data "aws_caller_identity" "current" {
}

resource "aws_default_vpc" "bootstrap" {
  tags = {
    Name = "DEFAULT"
  }
}

data "aws_route_table" "bootstrap" {
  vpc_id = aws_default_vpc.bootstrap.id
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_security_group" "bootstrap" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  ingress {
    from_port   = 4443
    to_port     = 4443
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  ingress {
    from_port   = 6868
    to_port     = 6868
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "bootstrap" {
  vpc = true
}

resource "aws_iam_role_policy" "iam_policy" {
  name   = "bootstrap"
  role   = aws_iam_role.iam_role.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role" "iam_role" {
  name               = "bootstrap"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "iam_profile" {
  name = "bootstrap"
  role = aws_iam_role.iam_role.name
}



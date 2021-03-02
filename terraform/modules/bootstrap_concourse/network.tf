resource "aws_default_vpc" "default" {
}

resource "aws_default_subnet" "default_az1" {
  vpc_id            = aws_default_vpc.default.id
  availability_zone = "us-gov-west-1a"
}


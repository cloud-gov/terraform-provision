resource "aws_security_group" "test_sg" {
  description = "Test terraform running under bootstrap"

  tags =  {
    Name = "Test terraform running under bootstrap"
  }
}
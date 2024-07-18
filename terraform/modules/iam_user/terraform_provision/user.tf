
resource "aws_iam_user" "terraform_provision" {
  name = "terraform-provision"
}

resource "aws_iam_user_policy_attachment" "terraform_provision" {
  user       = aws_iam_user.terraform_provision.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "iam_access_key_v1" {
  user = aws_iam_user.terraform_provision.name
}
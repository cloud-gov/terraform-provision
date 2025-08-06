data "aws_iam_policy_document" "concourse_iaas_worker_policy" {
  statement {
    actions = [
      "*"
    ]

    resources = [
      "*"
    ]
  }
}

// Grant IAAS worker admin permissions without using predefined `AdministratorAccess` policy
// so that terraform errors won't affect operator permissions
resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.concourse_iaas_worker_policy.json
}

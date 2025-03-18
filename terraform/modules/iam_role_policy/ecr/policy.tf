data "aws_iam_policy_document" "ecr_policy" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:BatchDeleteImage",
      "ecr:ListImages",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:GetDownloadUrlForLayer",
      "ecr:PutImageTagMutability"
    ]

    resources = [
      "arn:${var.aws_partition}:ecr:${var.aws_default_region}:${var.account_id}:repository/*"
    ]
  }

  statement {
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:GetAuthorizationToken",
      "ecr:DeleteLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:PutLifecyclePolicy"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.ecr_policy.json
}

data "template_file" "policy" {
  template = file("${path.module}/policy.json")

  vars = {
    aws_partition     = var.aws_partition
    buildpacks_bucket = var.buildpacks_bucket
    packages_bucket   = var.packages_bucket
    resources_bucket  = var.resources_bucket
    droplets_bucket   = var.droplets_bucket
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.template_file.policy.rendered
}

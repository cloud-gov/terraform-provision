// Use the RDS module instead of brokering a database inside Cloud Foundry.
// Eventually the CSB itself will broker RDS, so this avoids a circular dependency.
module "db" {
  source = "../../rds"

  stack_description               = var.stack_description
  rds_instance_type               = var.rds_instance_type
  rds_db_size                     = var.rds_db_size
  rds_db_engine                   = var.rds_db_engine
  rds_db_engine_version           = var.rds_db_engine_version
  rds_db_name                     = var.rds_db_name
  rds_username                    = var.rds_username
  rds_password                    = var.rds_password
  rds_subnet_group                = var.rds_subnet_group
  rds_security_groups             = var.rds_security_groups
  rds_parameter_group_family      = var.rds_parameter_group_family
  rds_allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  rds_apply_immediately           = var.rds_apply_immediately
}

data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.ecr_stack_name}/terraform.tfstate"
  }
}

locals {
  csb_ecr_repository_arn          = data.terraform_remote_state.ecr.outputs.repository_arns["csb"]
  csb_docproxy_ecr_repository_arn = data.terraform_remote_state.ecr.outputs.repository_arns["csb-docproxy"]
}

// A user with ECR pull permissions so Cloud Foundry can pull the CSB image.
module "ecr_user" {
  source          = "../../iam_user/ecr_pull_user"
  username        = "csb-ecr-${var.stack_description}"
  repository_arns = [local.csb_ecr_repository_arn, local.csb_docproxy_ecr_repository_arn]
}

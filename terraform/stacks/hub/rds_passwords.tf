resource "random_string" "concourse_prod_rds_password" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}


#  password                   = random_string.concourse_prod_rds_password.result
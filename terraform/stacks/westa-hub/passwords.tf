resource "random_string" "concourse_prod_rds_password" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}

resource "random_string" "credhub_rds_password" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}

resource "random_string" "credhub_prod_rds_password" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}

resource "random_string" "concourse_staging_rds_password" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}

resource "random_string" "credhub_staging_rds_password" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}

resource "random_string" "rds_password" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}

resource "random_string" "opsuaa_rds_password" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}


resource "random_string" "oidc_client_secret" {
  length = 32
  special = false
  min_special = 0
  min_upper = 5
  min_numeric = 5
  min_lower = 5
}


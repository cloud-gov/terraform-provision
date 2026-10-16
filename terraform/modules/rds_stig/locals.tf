locals {
  # Parameter/option group name: lowercase letters, digits and single hyphens,
  # no trailing hyphen. The family is included so an engine upgrade yields a
  # distinct group, since AWS will not let an existing group change family.
  # Keep the digits: "/[^a-zA-Z-]+/" dropped them, which both left a trailing
  # hyphen and collapsed mysql8.0 and mysql8.4 to one name.
  rds_group_name = trim(
    lower(
      replace(
        "${var.stack_description}-${var.rds_db_name}-${var.rds_parameter_group_family}",
        "/[^a-zA-Z0-9]+/",
        "-",
      )
    ),
    "-",
  )
}

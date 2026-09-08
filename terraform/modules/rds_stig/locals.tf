locals {
  # Derive a name that is valid for both aws_db_parameter_group and
  # aws_db_option_group. AWS requires: 1-255 characters, begins with a letter,
  # contains only letters, digits and hyphens, no two consecutive hyphens, and
  # must not end with a hyphen.
  #
  # The parameter group family is part of the name so that a major/minor engine
  # upgrade (for example mysql8.0 -> mysql8.4) produces a distinct group rather
  # than trying to mutate the family of an existing one, which AWS forbids.
  #
  # Digits MUST be preserved here. An earlier version of this expression used
  # "/[^a-zA-Z-]+/", which stripped the digits out of the family and so both
  # produced a trailing hyphen ("...-mysql-") and collapsed mysql8.0 and
  # mysql8.4 to the same name.
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

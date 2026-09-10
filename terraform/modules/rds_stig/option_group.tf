resource "aws_db_option_group" "option_group_mysql" {
  count = var.rds_db_engine == "mysql" ? 1 : 0
  name  = var.rds_option_group_name != "" ? var.rds_option_group_name : local.rds_group_name

  option_group_description = "MySQL STIG Option Group"
  engine_name              = var.rds_db_engine
  major_engine_version     = var.rds_db_engine_version

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }

  # Regarding major version updates:
  # DB snapshots record the option group they were taken with, so
  # backups reference the old option group until they age out of
  # backup_retention_period (35 days, per database.tf). Attempting to
  # delete the option group before then
  # fails with InvalidOptionGroupStateFault
  # ==========
  # HOWEVER, we do not use `skip_destroy = true`
  # because we don't want the option group to remain around forever.
  # Instead, we
  # - Do the major version update with TF (it will fail to delete the old option group)
  # - Connect to the CSB to run
  #     mysqldump -h 127.0.0.1 -u csb -p csb --set-gtid-purged=OFF > csb.sql
  # - Use the AWS console to do a manual snapshot of the new DB instance
  # - In the console, manually set the DB retention period to 0, applying immediately
  # - Once the snapshots are deleted, run `terraform plan/apply` again to delete the option group

  # The name changes on an engine upgrade, which forces replacement. Create the
  # new group before destroying the old one so the DB instance always has a
  # group to point at; AWS refuses to delete a group that is still in use.
  lifecycle {
    create_before_destroy = true
  }
}

variable DB_NAME {
  default = "bosh"
}

variable DB_SIZE {
  default = 5
}

variable DB_CLASS {
  #["db.t2.micro", "db.t2.small", "db.t2.medium", "db.t2.large db.r3.large", "db.r3.xlarge", "db.r3.2xlarge", "db.r3.4xlarge", "db.r3.8xlarge db.m4.large", "db.m4.xlarge", "db.m4.2xlarge", "db.m4.4xlarge", "db.m4.10xlarge"],

  default = "db.t2.micro"
}

variable DB_USERNAME {
  default = "postgres"
}

variable DB_PASSWORD {
  default = "figure-out-how-to-generate-this"
}

resource "aws_db_subnet_group" "postgres" {
  name = "rds_postgres"
  description = "${var.DESCRIPTION} (Multi-AZ Subnet Group)"
  subnet_ids = ["${aws_subnet.az1_rds.id}", "${aws_subnet.az2_rds.id}"]
}

resource "aws_db_instance" "postgres" {
  engine               = "postgres"
  engine_version       = "9.4"

  multi_az = true

  backup_retention_period = 30

  auto_minor_version_upgrade = true
  auto_minor_version_upgrade = false

  name = "${var.DB_NAME}"
  allocated_storage = "${var.DB_SIZE}"
  instance_class = "${var.DB_CLASS}"

  username = "${var.DB_USERNAME}"
  password = "${var.DB_PASSWORD}"

  db_subnet_group_name = "${aws_db_subnet_group.postgres.id}"
  vpc_security_group_ids = ["${aws_security_group.local_traffic.id}"]

  tags = {
    Name = "${var.DESCRIPTION}"
  }
}

variable "SECRETS_PASSPHRASE" {}
variable "PUBLIC_KEY_PATH" {}
variable "ACCESS_KEY_ID" {}
variable "SECRET_ACCESS_KEY" {}
variable "CF_S3_BUCKET" {
  default = "cf-templates-1v2czdpr8i6tw-us-gov-west-1"
}
variable "DEFAULT_REGION" {
  default = "us-east-1"
}

variable "AMI" {
  default = "ami-7e61de1f"
}

variable "CI_USER" {
  default = "ci"
}

variable "CI_PASS" {
  default = "walt"
}

provider "aws" {
  access_key = "${var.ACCESS_KEY_ID}"
  secret_key = "${var.SECRET_ACCESS_KEY}"
  region = "${var.DEFAULT_REGION}"
}

resource "aws_key_pair" "auth" {
  key_name = "testkey"
  public_key = "${file("${var.PUBLIC_KEY_PATH}")}"
}

resource "aws_security_group" "allow_ssh_and_web" {
  name = "allow_ssh_and_web"
  description = "Allow inbound ssh and web traffic"
  vpc_id = "vpc-4f897b2a"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_s3_bucket" "secrets_bucket" {
    bucket = "cloud-gov-varz"
    acl = "private"
    versioning {
      enabled = true
    }
}

resource "aws_s3_bucket" "tooling_blobstore_bucket" {
    bucket = "cloud-gov-bosh-tooling-blobstore"
    acl = "private"
}

resource "aws_s3_bucket_object" "tooling_bosh_secrets" {
    depends_on = [ "aws_s3_bucket.secrets_bucket" ]
    bucket = "${aws_s3_bucket.secrets_bucket.id}"
    key = "tooling-bosh.yml"
    source = "./tooling-bosh.enc.yml"
    etag = "${md5(file("./tooling-bosh.enc.yml"))}"
}

resource "aws_s3_bucket_object" "master_bosh_secrets" {
    depends_on = [ "aws_s3_bucket.secrets_bucket" ]
    bucket = "${aws_s3_bucket.secrets_bucket.id}"
    key = "master-bosh.yml"
    source = "./master-bosh.enc.yml"
    etag = "${md5(file("./master-bosh.enc.yml"))}"
}

resource "aws_s3_bucket_object" "master_bosh_cert" {
    depends_on = [ "aws_s3_bucket.secrets_bucket" ]
    bucket = "${aws_s3_bucket.secrets_bucket.id}"
    key = "master-bosh.pem"
    source = "./master-bosh.enc.pem"
    etag = "${md5(file("./master-bosh.enc.pem"))}"
}

resource "aws_s3_bucket_object" "master_bosh_init_state" {
    depends_on = [ "aws_s3_bucket.secrets_bucket" ]
    bucket = "${aws_s3_bucket.secrets_bucket.id}"
    key = "master-bosh-state.json"
    content = "{}"
}

resource "aws_instance" "example" {
  depends_on = [ "aws_s3_bucket_object.master_bosh_secrets",
    "aws_s3_bucket_object.master_bosh_cert",
    "aws_s3_bucket_object.master_bosh_init_state"
  ]
  ami = "${var.AMI}"
  instance_type = "c1.medium"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = [ "sg-2128f844", "${aws_security_group.allow_ssh_and_web.id}" ]
  subnet_id = "subnet-479a1922"

  associate_public_ip_address = true

  connection {
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"CI_USER=${var.CI_USER}\\nCI_PASS=${var.CI_PASS}\\nCI_HOST=${aws_instance.example.public_ip}\" > ~/info.sh",
      "./start_concourse.sh",
      "screen -list; exit 0;"
    ]
  }
  provisioner "local-exec" {
      command = <<EOC
until nc -z ${aws_instance.example.public_ip} 80; do sleep 1; done && \
fly -t boot login -c http://${aws_instance.example.public_ip} -u ${var.CI_USER} -p ${var.CI_PASS} && \
until fly -t boot workers 2>&1| grep linux; do sleep 1; done && \
fly -t boot set-pipeline -n -p bootstrap -c pipeline.yml -v aws_access_key_id=${var.ACCESS_KEY_ID} \
  -v aws_secret_access_key=${var.SECRET_ACCESS_KEY} -v aws_default_region=${var.DEFAULT_REGION} \
  -v aws_s3_bucket=${var.CF_S3_BUCKET} -v passphrase=${var.SECRETS_PASSPHRASE} \
  -v aws_secrets_bucket="${aws_s3_bucket.secrets_bucket.id}" && \
fly -t boot unpause-pipeline -p bootstrap && \
fly -t boot trigger-job -j bootstrap/bootstrap
EOC
  }
}

output "concourse_url" {
  value = "http://${var.CI_USER}:${var.CI_PASS}@${aws_instance.example.public_ip}/login/basic"
}
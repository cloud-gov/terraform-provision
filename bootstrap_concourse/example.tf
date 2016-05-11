variable "PUBLIC_KEY_PATH" {}
variable "ACCESS_KEY_ID" {}
variable "SECRET_ACCESS_KEY" {}
variable "DEFAULT_REGION" {
  default = "us-east-1"
}

variable "AMI" {
  default = "ami-64140d0e"
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

resource "aws_security_group" "allow_all_tcp" {
  name = "allow_all_tcp"
  description = "Allow all inbound traffic"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami = "${var.AMI}"
  instance_type = "m1.small"
  key_name = "${aws_key_pair.auth.id}"
  security_groups = ["${aws_security_group.allow_all_tcp.name}"]

  connection {
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "psql -V || sudo apt-get update && sudo apt-get update",
      "sudo apt-get install -y postgresql screen",
      "sudo -u postgres psql -c \"CREATE USER ubuntu WITH PASSWORD 'ci';\"",
      "sudo -u postgres createdb -O ubuntu atc",
      "sudo iptables -t nat -F && sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080",
      "test -f host_key || ssh-keygen -t rsa -f host_key -N ''",
      "test -f worker_key || ssh-keygen -t rsa -f worker_key -N ''",
      "test -f session_signing_key || ssh-keygen -t rsa -f session_signing_key -N ''",
      "test -f authorized_worker_keys || cp worker_key.pub authorized_worker_keys",
      "test -f concourse_linux_amd64 || curl -LO https://github.com/concourse/concourse/releases/download/v1.2.0/concourse_linux_amd64",
      "echo \"sleep 10 && screen -dmS web ./concourse_linux_amd64 web --basic-auth-username ${var.CI_USER} --basic-auth-password ${var.CI_PASS}  --session-signing-key session_signing_key --tsa-host-key host_key --tsa-authorized-keys authorized_worker_keys --postgres-data-source='postgres://ubuntu:ci@127.0.0.1:5432/atc?sslmode=disable' --external-url http://${aws_instance.example.public_ip}\" > start_concourse.sh",
      "echo \"sudo mkdir -p /opt/worker && screen -dmS worker sudo ./concourse_linux_amd64 worker --work-dir /opt/worker --tsa-host 127.0.0.1 --tsa-public-key host_key.pub --tsa-worker-private-key worker_key\" >> start_concourse.sh",
      "chmod 755 concourse_linux_amd64 start_concourse.sh",
      "./start_concourse.sh",
      "screen -list; exit 0;"
    ]
  }
  provisioner "local-exec" {
      command = <<EOC
until nc -z ${aws_instance.example.public_ip} 80; do sleep 1; done && \
fly -t boot login -c http://${aws_instance.example.public_ip} -u ${var.CI_USER} -p ${var.CI_PASS} && \
until fly -t boot workers 2>&1| grep linux; do sleep 1; done && \
fly -t boot set-pipeline -n -p bootstrap -c pipeline.yml && \
fly -t boot unpause-pipeline -p bootstrap && \
fly -t boot trigger-job -j bootstrap/bootstrap
EOC
  }
}

output "concourse_url" {
  value = "http://${var.CI_USER}:${var.CI_PASS}@${aws_instance.example.public_ip}/"
}
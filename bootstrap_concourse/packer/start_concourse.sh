#!/bin/sh

set -e 

. ./info.sh

# route 80 to concourse
sudo iptables -t nat -F && sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

screen -dmS web ./concourse_linux_amd64 web --basic-auth-username $CI_USER --basic-auth-password $CI_PASS  --session-signing-key session_signing_key --tsa-host-key host_key --tsa-authorized-keys authorized_worker_keys --postgres-data-source='postgres://ubuntu:ci@127.0.0.1:5432/atc?sslmode=disable' --external-url http://$CI_HOST

mkdir -p /mnt/worker && screen -dmS worker sudo ./concourse_linux_amd64 worker --work-dir /mnt/worker --tsa-host 127.0.0.1 --tsa-public-key host_key.pub --tsa-worker-private-key worker_key

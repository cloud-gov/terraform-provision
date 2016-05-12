#!/bin/sh

set -e 

# https://bugs.launchpad.net/ubuntu/+source/screen/+bug/574773
until test -d /var/run/screen; do sleep 5; done;

. ./info.sh

# route 80 to concourse
sudo iptables -t nat -F && sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

screen -dmS web /bin/bash -c "./concourse_linux_amd64 web --basic-auth-username $CI_USER --basic-auth-password $CI_PASS  --session-signing-key session_signing_key --tsa-host-key host_key --tsa-authorized-keys authorized_worker_keys --postgres-data-source='postgres://ubuntu:ci@127.0.0.1:5432/atc?sslmode=disable' --external-url http://$CI_HOST | tee web.log"

sudo mkdir -p /mnt/worker && screen -dmS worker sudo /bin/bash -c "./concourse_linux_amd64 worker --work-dir /mnt/worker --tsa-host 127.0.0.1 --tsa-public-key host_key.pub --tsa-worker-private-key worker_key | tee worker.log"

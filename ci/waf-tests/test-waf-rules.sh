#!/bin/bash

set -ex

python3 -m venv venv
# this file doesn't exist for shellcheck to check, but we know it will exist later
# shellcheck disable=SC1091
source venv/bin/activate

cd ./cg-provision-repo/ci/waf-tests/

python3 -m pip install -r requirements.txt

pytest -v

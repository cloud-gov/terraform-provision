#!/bin/bash

set -ex

python3 -m venv venv
source venv/bin/activate

cd ./cg-provision-repo/ci/waf-tests/

python3 -m pip install -r requirements.txt

pytest -v

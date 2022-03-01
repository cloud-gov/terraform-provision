#!/bin/bash

set -ex

python3 -m venv venv
source venv/bin/activate

python3 -m pip install -r ./cg-provision-repo/ci/requirements.txt

cd ./waf-rule-tests-development

pytest -v

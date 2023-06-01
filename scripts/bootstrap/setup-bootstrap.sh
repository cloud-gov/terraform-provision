#!/bin/bash

set -eux

# Clone necessary git repositories
git clone https://github.com/concourse/concourse-deployment
git clone https://github.com/cloud-gov/cg-deploy-bosh
git clone https://github.com/cloud-gov/cg-deploy-concourse
git clone https://github.com/cloud-gov/cg-pipeline-tasks
git clone https://github.com/cloud-gov/cg-scripts
git clone https://github.com/cloud-gov/cg-secret-rotation

#!/bin/bash

set -eux

# Clone necessary git repositories
git clone https://github.com/concourse/concourse-deployment
git clone https://github.com/18F/cg-deploy-bosh
git clone https://github.com/18F/cg-deploy-concourse
git clone https://github.com/18F/cg-pipeline-tasks
git clone https://github.com/18F/cg-scripts
git clone https://github.com/18F/cg-secret-rotation

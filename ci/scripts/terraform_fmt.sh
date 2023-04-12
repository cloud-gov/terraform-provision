#!/bin/bash
set -e

terraform fmt -recursive
git diff-index --quiet HEAD -- # exit 1 if dirty, 0 otherwise

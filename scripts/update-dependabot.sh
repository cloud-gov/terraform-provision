#!/bin/bash

# delete the exising configuration since it will be overridden
yq -i 'del(.updates)' ".github/dependabot.yml"

for DIR in $(find . -name '*.tf' -not -path '*.terraform*'  -exec dirname {} \; | sort -u); do
  dir=${DIR:1} \
  yq -i '."updates"+=[{"package-ecosystem":"terraform" | . style="double","directory":env(dir) | . style="double","schedule":{"interval":"weekly" | . style="double"}}]' \
  .github/dependabot.yml
done
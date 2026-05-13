#!/bin/bash
set -e

# what has changed since the last commit
changed=$(git diff --name-only HEAD~1..HEAD | xargs -I{} dirname {} | sort -u)

for d in $changed ; do
  # get the second element of the path. this way we can
  # can determine if the changes happened in a directory where
  # we can actually build something
  platform=$(echo $d | cut -d/ -f2 | sort -u)
  if [[ "$platform" != "paper" && "$platform" != "velocity" ]]; then
    echo "skipping $platform"
    continue
  fi

  blueprint=$(echo $d | cut -d/ -f1-3 | sort -u)

  echo "building $blueprint"
  cd $blueprint

  sha=$(git rev-parse HEAD)
  name=$(cat config.pkrvars.json | jq -r .name)
  tag=ghcr.io/spacechunks/blueprints/$name:$sha

  tmp=$(mktemp)
  jq --arg new "$sha" '.version = $new' config.pkrvars.json > "$tmp" && mv "$tmp" config.pkrvars.json

  packer build -parallel-builds=1 -var-file=config.pkrvars.json "../../templates/$platform.pkr.hcl"

  cd -
done

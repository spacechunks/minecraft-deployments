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

  # run in subshell so we don't have to cd out of the blueprint again
  (
    cd $blueprint

    name=$(cat config.pkrvars.json | jq -r .name)
    version=$(cat config.pkrvars.json | jq -r .version)
    tag=ghcr.io/spacechunks/blueprints/$name:$version

    exists=$(docker manifest inspect $tag > /dev/null ; echo $?)

    if [ $exists == 0 ]; then
      echo "$tag already exists. skipping."
      continue
    fi

    sops -d secrets.pkrvars.sops.json > secrets.pkrvars.json

    packer build -parallel-builds=1 -var-file=config.pkrvars.json -var-file=secrets.pkrvars.json "../../../templates/$platform.pkr.hcl"
  )
done

#!/bin/bash
set -e

bump_version() {
  prev="$1"
  year=$(date +%Y)
  week=$(date +%V)
  release=$(echo "$prev" | awk -F. -v y="$year" -v w="$week" '
    $1==y && $2==w { print $3+1; exit }
    { print 1 }
  ')

  echo "$year.$week.$release"
}

cd blueprints/$1

old_version=$(cat config.pkrvars.json | jq -r .version)
new_version=$(bump_version $old_version)

sha=$(git rev-parse HEAD)
name=$(cat config.pkrvars.json | jq -r .name)
rev_tag=ghcr.io/spacechunks/blueprints/$name:$sha
new_version_tag=ghcr.io/spacechunks/blueprints/$name:$new_version

# only when building is successful we want to update the version
tmp=$(mktemp)
jq --arg new "$new_version" '.version = $new' config.pkrvars.json > "$tmp" && mv "$tmp" config.pkrvars.json

docker image pull $rev_tag
docker image tag $rev_tag $new_version_tag
docker push $new_version_tag

if [ -z "$(git status --porcelain)" ]; then
  echo "no changes detected. exiting."
  exit 0
fi

git pull --rebase
git diff
git config --local user.email "tobor@chunks.cloud"
git config --local user.name "tobor"
git commit -a -m "[no ci] $1: update $old_version to $new_version" -m "git sha: $sha"
git push

#!/bin/bash
set -e

function build() {
  version=$(cat config.pkrvars.json | jq -r .version)
  name=$(cat config.pkrvars.json | jq -r .name)
  tag=ghcr.io/spacechunks/$name:$version
  exists=$(docker manifest inspect $tag > /dev/null ; echo $?)

  if [ "$1" == "base" ]; then
    # export the version, so we don't have to
    # set them when running packer build.
    # see sources.pkr.hcl for reference
    export BUILD_PAPER_VERSION=$version
  fi

  if [ $exists == 0 ]; then
    echo "$tag already exists. skipping."
    return
  fi

  packer build -var-file=config.pkrvars.json .
}

docker login $BUILD_OCI_REG_SERVER -u $BUILD_OCI_REG_USER -p $BUILD_OCI_REG_PASS

cd base
build base
cd ..
cd blueprints

for dir in */ ; do
  mode=$(basename $dir)
  echo "build $mode"
  cd $mode
  build $mode
  cd ..
done

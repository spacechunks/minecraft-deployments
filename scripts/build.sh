#!/bin/bash
set -e

function build() {
  version=$(cat config.pkrvars.json | jq -r .version)
  name=$(cat config.pkrvars.json | jq -r .name)
  tag=ghcr.io/spacechunks/blueprints/$name:$version
  exists=$(docker manifest inspect $tag > /dev/null ; echo $?)

  if [ $exists == 0 ]; then
    echo "$tag already exists. skipping."
    return
  fi

  packer build -parallel-builds=1 -var-file=config.pkrvars.json ../blueprint.pkr.hcl
}

docker login $BUILD_OCI_REG_SERVER -u $BUILD_OCI_REG_USER -p $BUILD_OCI_REG_PASS

cd blueprints/paper

for dir in */ ; do
  mode=$(basename $dir)
  echo "build $mode"
  cd $mode
  build $mode
  cd ..
done

cd ../..
cd blueprints/velocity

for dir in */ ; do
  mode=$(basename $dir)
  echo "build $mode"
  cd $mode
  build $mode
  cd ..
done

cd ../..

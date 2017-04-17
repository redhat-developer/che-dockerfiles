#!/bin/bash
# A script to build and publish Docker images for Che workspaces
# please send PRs to github.com/redhat-developer/che-dockerfiles

# this script assumes its being run on CentOS Linux 7/x86_64

set -u
set +e

# Source build variables
cat jenkins-env | grep PASS > inherit-env
. inherit-env

# Update machine, get required deps in place
yum -y update
yum -y install docker git

exit_with_error="no"
git_tag=$(git rev-parse --short HEAD)

docker login -u rhchebot -p $RHCHEBOT_DOCKER_HUB_PASSWORD -e noreply@redhat.com

for d in recipes/*/ ; do
  image=$(basename $d)

  echo "Building $image"
  docker build -t ${image} ${d}
  if [ $? -ne 0 ]; then
     echo 'ERROR: Docker build failed'
     exit_with_error="yes"
     continue
  fi
  echo 'Image built successfully'  

  declare -a tags=(rhche/${image}:latest
                   rhche/${image}:${git_tag}
                   registry.devshift.net/che/${image}:latest
                   registry.devshift.net/che/${image}:${git_tag})
  
  for new_tag in "${tags[@]}"; do
    echo "Tagging ${new_tag}"
    docker tag ${image}:latest ${new_tag}
    echo "Pushing ${new_tag}"
    docker push ${new_tag}
  done

done

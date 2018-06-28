#!/bin/bash
# A script to build and publish Docker images for Che workspaces
# please send PRs to github.com/redhat-developer/che-dockerfiles

# this script assumes its being run on CentOS Linux 7/x86_64

set -u
set -e

# Source build variables
cat jenkins-env | grep -e RHCHEBOT_DOCKER_HUB_PASSWORD -e DEVSHIFT > inherit-env
. inherit-env

# Update machine, get required deps in place
yum -y update
yum -y install docker git

systemctl start docker

exit_with_error="no"
git_tag=$(git rev-parse --short HEAD)

for d in recipes/*/ ; do
  image=$(basename $d)

  ./build_dockerfile.sh $d
  if [ $? -ne 0 ]; then
    echo 'ERROR: Docker build failed'
    exit_with_error="yes"
    continue
  fi
  echo 'Image built successfully'

  # Pushing to DockerHub
  docker login -u rhchebot -p $RHCHEBOT_DOCKER_HUB_PASSWORD -e noreply@redhat.com

  declare -a tags_dockerhub=(rhche/${image}:latest
                             rhche/${image}:${git_tag})

  for new_tag in "${tags_dockerhub[@]}"; do
    echo "Tagging ${new_tag}"
    docker tag ${image}:latest ${new_tag}
    echo "Pushing ${new_tag}"
    docker push ${new_tag}
  done

  # Pushing to 'push.registry.devshift.net'
  docker login -u $DEVSHIFT_USERNAME -p $DEVSHIFT_PASSWORD push.registry.devshift.net

  declare -a tags_devshift=(push.registry.devshift.net/che/${image}:latest
                            push.registry.devshift.net/che/${image}:${git_tag})

  for new_tag in "${tags_devshift[@]}"; do
    echo "Tagging ${new_tag}"
    docker tag ${image}:latest ${new_tag}
    echo "Pushing ${new_tag}"
    docker push ${new_tag}
  done

done

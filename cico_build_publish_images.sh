#!/bin/bash
# A script to build and publish Docker images for Che workspaces
# please send PRs to github.com/redhat-developer/che-dockerfiles

# this script assumes its being run on CentOS Linux 7/x86_64

set -u
set -e

# Source build variables
cat jenkins-env | grep -e RHCHEBOT_DOCKER_HUB_PASSWORD -e DEVSHIFT -e QUAY > inherit-env
. inherit-env

# Update machine, get required deps in place
yum -y update
yum -y install docker git

systemctl start docker

exit_with_error="no"
git_tag=$(git rev-parse --short HEAD)

for d in recipes/dockerfiles/*/ ; do
  image=$(basename $d)

  echo "Building $image"
  docker build -t ${image} -f ${d}/Dockerfile ./recipes | cat
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
    docker push ${new_tag} | cat
  done

  # Pushing to 'quay.io'
  if [ -n "${QUAY_USERNAME}" -a -n "${QUAY_PASSWORD}" ]; then
    docker login -u ${QUAY_USERNAME} -p ${QUAY_PASSWORD} quay.io
  else
    echo "Could not login, missing credentials for the registry"
  fi

  declare -a tags_quay=(quay.io/openshiftio/che-${image}:latest
                            quay.io/openshiftio/che-${image}:${git_tag})

  for new_tag in "${tags_quay[@]}"; do
    echo "Tagging ${new_tag}"
    docker tag ${image}:latest ${new_tag}
    echo "Pushing ${new_tag}"
    docker push ${new_tag} | cat
  done

done

#!/bin/bash
# Copyright (c) 2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
#

set -e
set -u

get_branch() {
  echo "${1}" | grep "gitRef" | awk -F : '{print $2}' | xargs
}

get_repository() {
  echo "https://github.com/$(echo "${1}" | grep "githubRepo" | awk -F : '{print $2}' | xargs)"
}

git_clone_and_build() {
  CONTENT=$(curl -s "${1}")
  BRANCH=$(get_branch "${CONTENT}")
  REPOSITORY=$(get_repository "${CONTENT}")
  cd "${HOME}"
  CURRENT_FOLDER=$(pwd)

  echo "cloning with git clone -b ${BRANCH} ${REPOSITORY} tmp-folder"

  git clone -b "${BRANCH}" "${REPOSITORY}" tmp-folder
  cd tmp-folder && scl enable rh-maven33 'mvn clean package'
  cd "${CURRENT_FOLDER}" && rm -rf tmp-folder
}

git_clone_and_build https://raw.githubusercontent.com/openshiftio/booster-catalog/v10/configmap/spring-boot/spring-boot-configmap-booster.yaml
git_clone_and_build https://raw.githubusercontent.com/openshiftio/booster-catalog/v10/health-check/spring-boot/spring-boot-health-check-booster.yaml
git_clone_and_build https://raw.githubusercontent.com/openshiftio/booster-catalog/v10/rest-http/spring-boot/spring-boot-rest-http-booster.yaml

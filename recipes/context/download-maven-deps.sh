#!/bin/bash
# Copyright (c) 2018 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
#
# Download maven dependencies needed to build a booster project by cloning a github
# repo and executing `mvn clean package`. Deletes downloaded artifacts afterwards.
#
# see https://forge.api.openshift.io/api/booster-catalog for a list of boosters
#
# usage:
#   ./download-maven-deps.sh <mission> [<runtimes>]
# e.g.:
#   ./download-maven-deps.sh 'wildfly-swarm' 'health-check' 'rest-http'
##################################

set -e
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

##
# Clone and run `mvn clean package` on a repository, removing all
# downloaded files after completion. Used to download dependencies
# to the local maven repository.
#
# params:
# ${1} - Repository to download
# ${2} - branch/tag to check out
##
git_clone_and_build() {
  REPOSITORY=${1}
  BRANCH=${2}
  cd "${HOME}"
  CURRENT_FOLDER=$(pwd)

  echo "cloning with git clone -b ${BRANCH} ${REPOSITORY} tmp-folder"

  git clone -b "${BRANCH}" "${REPOSITORY}" tmp-folder
  cd tmp-folder && scl enable rh-maven33 'mvn -B clean package'
  cd "${CURRENT_FOLDER}" && rm -rf tmp-folder
}

##
# Use curl to get booster catalog json file if it does not already exist
#
# Documentation on this endpoint is available at https://forge.api.openshift.io/swagger.yaml.
# In particular, the `X-App: osio` header tells the server that only boosters supported on
# OSIO should be returned.
##
cache_boosters_catalog() {
  if [ ! -f ${SCRIPT_DIR}/booster-catalog.json ]; then
    curl -H "X-App: osio" \
      https://forge.api.openshift.io/api/booster-catalog \
      > ${SCRIPT_DIR}/booster-catalog.json
  fi
}

cache_boosters_catalog

RUNTIME=${1}
shift
for MISSION in "$@"; do
  echo "Downloading maven deps for runtime: " $RUNTIME " - " $MISSION
  BOOSTER=$(
    jq --arg MISSION $MISSION \
        --arg RUNTIME $RUNTIME \
        '.boosters
        | .[]
        | select(
          .mission == $MISSION and
          .runtime == $RUNTIME
        )' \
      ${SCRIPT_DIR}/booster-catalog.json
  )
  URL=$(echo $BOOSTER | jq -r '.source.git.url')
  REF=$(echo $BOOSTER | jq -r '.source.git.ref')

  git_clone_and_build $URL $REF
done
rm "${SCRIPT_DIR}/booster-catalog.json"

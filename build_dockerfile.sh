#!/bin/bash
# Copyright (c) 2018 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
#
set -u

UTIL_DIR="/util"

if [[ $# -ne 1 ]]; then
  echo "Usage: ./build_dockerfile.sh <DIR>"
  exit 1
fi
d=${1}
if [[ ! -d ${d} ]]; then
  echo "Specified directory does not exist"
  exit 1
fi
image=$(basename $d)

build_succeded=true

echo "Building $image"
echo "  1. Copying helper scripts to build directory"
cp -r ./${UTIL_DIR} ${d}/${UTIL_DIR}

echo "  2. Executing docker build"
docker build -t ${image} ${d}
build_succeded=$?

echo "  3. Cleaning up"
rm -r ${d}/${UTIL_DIR}

exit $build_succeded

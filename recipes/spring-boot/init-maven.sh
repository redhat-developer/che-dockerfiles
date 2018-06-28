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

DIR=$(cd "$(dirname "$0")"; pwd)

. $DIR/build.include

download_maven_deps "spring-boot" "configmap"
download_maven_deps "spring-boot" "health-check"
download_maven_deps "spring-boot" "rest-http"


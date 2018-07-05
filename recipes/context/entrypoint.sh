#!/bin/bash
# Copyright (c) 2012-2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

set -e

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

if ! grep -Fq "${USER_ID}" /etc/passwd; then
    envsubst < ${HOME}/passwd.template > /etc/passwd
    envsubst < ${HOME}/group.template > /etc/group

    # The trick below is the one that is suggested here
    # https://docs.openshift.com/enterprise/3.2/creating_images/guidelines.html#openshift-enterprise-specific-guidelines
    # But every new exec call won't work because 
    # LD_PRELOAD, NSS_WRAPPER_PASSWD and NSS_WRAPPER_GROUP
    # are not set there.
    #
    # envsubst < ${HOME}/passwd.template > /tmp/passwd
    # envsubst < ${HOME}/group.template > /tmp/group
    # export LD_PRELOAD=/usr/local/lib/libnss_wrapper.so
    # export NSS_WRAPPER_PASSWD=/tmp/passwd
    # export NSS_WRAPPER_GROUP=/tmp/group
    touch ${HOME}/is_arbitrary_user
fi

# SSH agent is currently not supported but if we
# do want to support it we can uncomment the code below
# and fix SSHAgentLauncher that has SSHD port hardcoded
# to 22 and will expect the service to be available at that
# port. And we cannot use port 22 because it's a 
# privileged port and OpenShift will complain.
#
# SSHD_PORT=2222
# /usr/bin/ssh-keygen -A
# mkdir -p /home/user/.ssh
# chmod 700 /home/user/.ssh
# echo "UsePrivilegeSeparation no" > /home/user/.ssh/sshd_config
# /usr/sbin/sshd -D -p ${SSHD_PORT} -f /home/user/.ssh/sshd_config &

exec "$@"

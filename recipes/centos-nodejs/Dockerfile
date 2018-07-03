# Copyright (c) 2012-2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

FROM registry.centos.org/che-stacks/centos-nodejs

ARG JAVA_VERSION=1.8.0
ARG OC_VERSION=3.6.173.0.30

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}

# Install general dependencies
COPY --chown=user:user ["./general-deps.install", "/tmp/install/"]
RUN /tmp/install/general-deps.install ${OC_VERSION} ${JAVA_VERSION} && \
    rm -rf /tmp/install

# Install nss_wrapper
COPY --chown=user:user ["./nss_wrapper.install", "/tmp/install/"]
RUN /tmp/install/nss_wrapper.install && \
    rm -rf /tmp/install

# Give write access to /home/user for users with an arbitrary UID
COPY --chown=user:user ["./grant-access-arbitrary-UID.sh", "/tmp/install/"]
RUN /tmp/install/grant-access-arbitrary-UID.sh && \
    rm -rf /tmp/install

# The following lines are needed to set the correct locale after `yum update`
# c.f. https://github.com/CentOS/sig-cloud-instance-images/issues/71
RUN sudo localedef -i en_US -f UTF-8 C.UTF-8
ENV LANG="C.UTF-8"

# Generate passwd.template
RUN cat /etc/passwd | \
    sed s#user:x.*#user:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/bash#g \
    > /home/user/passwd.template

# Generate group.template
RUN cat /etc/group | \
    sed s#root:x:0:#root:x:0:0,\${USER_ID}:#g \
    > /home/user/group.template

ENV HOME /home/user

# Overwride entrypoint
COPY ["entrypoint.sh","/home/user/entrypoint.sh"]
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null

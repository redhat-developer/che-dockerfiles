# Copyright (c) 2012-2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

FROM registry.centos.org/che-stacks/wildfly-swarm

ARG OC_VERSION=3.6.173.0.30

RUN sudo yum list installed

# Install general dependencies
COPY ["./context/general-deps.install", "/tmp/install/"]
RUN sudo chown user:user /tmp/install /tmp/install/* && \
    /tmp/install/general-deps.install ${OC_VERSION} && \
    sudo rm -rf /tmp/install

# Install nss_wrapper
COPY ["./context/nss_wrapper.install", "/tmp/install/"]
RUN sudo chown user:user /tmp/install /tmp/install/* && \
    /tmp/install/nss_wrapper.install && \
    sudo rm -rf /tmp/install

# Install nodejs
COPY ["./context/nodejs.install", "/tmp/install/"]
RUN sudo chown user:user /tmp/install /tmp/install/* && \
    /tmp/install/nodejs.install && \
    sudo rm -rf /tmp/install

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
COPY ["./context/entrypoint.sh","/home/user/entrypoint.sh"]
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null

# Download maven dependencies
COPY ["./context/download-maven-deps.sh", \
      "./context/maven-deps.install", \
      "/tmp/maven-deps/"]
ADD https://api.github.com/repos/openshiftio/booster-catalog/git/refs/tags/v10 /tmp/current-osio-sha1
RUN sudo chown user:user /tmp/maven-deps /tmp/maven-deps/* && \
    /tmp/maven-deps/maven-deps.install \
        'wildfly-swarm' \
        # 'configmap' \
        'health-check' \
        'rest-http' && \
    sudo rm -rf /tmp/maven-deps

# Give write access to /home/user for users with an arbitrary UID
COPY ["./context/grant-access-arbitrary-UID.sh", "/tmp/install/"]
RUN sudo chown user:user /tmp/install /tmp/install/* && \
    /tmp/install/grant-access-arbitrary-UID.sh && \
    sudo rm -rf /tmp/install

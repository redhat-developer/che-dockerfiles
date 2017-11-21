# Copyright (c) 2012-2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

FROM registry.centos.org/che-stacks/spring-boot

ARG OC_VERSION=3.6.173.0.30

# Install nss_wrapper and gettext
RUN sudo yum update -y && \
    sudo yum install -y cmake gettext make gcc git && \
    cd /home/user/ && \
    git clone git://git.samba.org/nss_wrapper.git && \
    cd nss_wrapper && \
    mkdir obj && cd obj && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DLIB_SUFFIX=64 .. && \
    make && sudo make install && \
    cd /home/user && rm -rf ./nss_wrapper && \
    sudo yum remove -y cmake make gcc && \
    sudo yum clean all && \
    sudo rm -rf /tmp/* /var/cache/yum

# Install nodejs for ls agents and OpenShift CLI
RUN sudo yum update -y && \
    curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash - && \
    sudo yum install -y bzip2 tar curl wget nodejs && \
    sudo wget -qO- "https://mirror.openshift.com/pub/openshift-v3/clients/${OC_VERSION}/linux/oc.tar.gz" | sudo tar xvz -C /usr/local/bin && \
    sudo yum remove -y wget && \
    sudo yum clean all && \
    sudo rm -rf /tmp/* /var/cache/yum

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

# Set _JAVA_OPTIONS environment variable so as to make spawned
# java processes respect the container limit and use reasonable
# GC configuration for small JVMs.
ENV _JAVA_OPTIONS "-XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Dsun.zip.disableMemoryMapping=true -Xms20m"

# Overwride entrypoint
COPY ["entrypoint.sh","/home/user/entrypoint.sh"]

ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null

COPY ["init-maven.sh","/tmp/init-maven.sh"]
ADD https://api.github.com/repos/openshiftio/booster-catalog/git/refs/tags/v10 /tmp/current-osio-sha1
RUN sudo chown user:user /tmp/init-maven.sh && \
    chmod +x /tmp/init-maven.sh && \
    /tmp/init-maven.sh && \
    sudo rm -f /tmp/init-maven.sh /tmp/current-osio-sha1

# Give write access to /home/user for
# users with an arbitrary UID
RUN sudo chgrp -R 0 /home/user \
  && sudo chmod -R g+rwX /home/user \
  && sudo chgrp -R 0 /etc/passwd \
  && sudo chmod -R g+rwX /etc/passwd \
  && sudo chgrp -R 0 /etc/group \
  && sudo chmod -R g+rwX /etc/group \
  && sudo mkdir -p /projects \
  && sudo chgrp -R 0 /projects \
  && sudo chmod -R g+rwX /projects \
  && sudo chgrp -R 0 /tmp \
  && sudo chmod -R g+rwX /tmp

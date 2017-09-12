# Copyright (c) 2012-2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

FROM eclipse/ubuntu_jdk8:latest

ARG OC_VERSION=3.6.173.0.30

# Install nss_wrapper and gettext
RUN sudo apt-get update && \
    sudo apt-get install -y cmake gettext && \
    cd /home/user/ && \
    git clone git://git.samba.org/nss_wrapper.git && \
    cd nss_wrapper && \
    mkdir obj && cd obj && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local /home/user/nss_wrapper/ && \
    make && sudo make install && \
    cd /home/user && rm -rf ./nss_wrapper && \
    sudo apt-get remove -y cmake gettext && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Install nodejs for ls agents and OpenShift CLI
RUN sudo apt-get update && \
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && \
    sudo apt-get install -y bzip2 tar curl wget nodejs && \
    sudo wget -qO- "https://mirror.openshift.com/pub/openshift-v3/clients/${OC_VERSION}/linux/oc.tar.gz" | sudo tar xvz -C /usr/local/bin && \
    sudo apt-get remove -y wget && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Give write access to /home/user for 
# users with an arbitrary UID 
RUN sudo chgrp -R 0 /home/user \
  && sudo chmod -R g+rwX /home/user \
  && sudo chgrp -R 0 /etc/passwd \
  && sudo chmod -R g+rwX /etc/passwd \
  && sudo chgrp -R 0 /etc/group \
  && sudo chmod -R g+rwX /etc/group \
  && sudo chgrp -R 0 /projects \
  && sudo chmod -R g+rwX /projects
  
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

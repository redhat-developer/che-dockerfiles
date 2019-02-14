# Copyright (c) 2012-2018 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

FROM registry.centos.org/che-stacks/centos-stack-base:latest

ENV RUBY_MAJOR_VERSION=2 \
    RUBY_MINOR_VERSION=5
ENV RUBY_SCL_NAME_VERSION="${RUBY_MAJOR_VERSION}${RUBY_MINOR_VERSION}"
ENV RUBY_VERSION="${RUBY_MAJOR_VERSION}.${RUBY_MINOR_VERSION}" \
    RUBY_SCL="rh-ruby${RUBY_SCL_NAME_VERSION}"
ENV PATH=/home/user/bin:/opt/rh/rh-ruby25/root/usr/local/bin:/opt/rh/rh-ruby25/root/usr/bin${PATH:+:${PATH}} \
    LD_LIBRARY_PATH=/opt/rh/rh-ruby25/root/usr/local/lib64:/opt/rh/rh-ruby25/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
    MANPATH=/opt/rh/rh-ruby25/root/usr/local/share/man:/opt/rh/rh-ruby25/root/usr/share/man:$MANPATH \
    PKG_CONFIG_PATH=/opt/rh/rh-ruby25/root/usr/local/lib64/pkgconfig:/opt/rh/rh-ruby25/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} \
    XDG_DATA_DIRS=/opt/rh/rh-ruby25/root/usr/local/share:/opt/rh/rh-ruby25/root/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share} \
    OC_VERSION=3.9.38

USER root

RUN yum install -y -d 1 \
        centos-release-scl-rh && \
    yum-config-manager --add-repo https://cbs.centos.org/repos/sclo7-rh-ruby25-rh-candidate/x86_64/os/ && \
    echo gpgcheck=0 >> /etc/yum.repos.d/cbs.centos.org_repos_sclo7-rh-ruby25-rh-candidate_x86_64_os_.repo && \
    INSTALL_PKGS=" \
        ${RUBY_SCL} \
        ${RUBY_SCL}-ruby-devel \
        ${RUBY_SCL}-rubygem-rake \
        ${RUBY_SCL}-rubygem-bundler" && \
    yum install -y -d 1 --setopt=tsflags=nodocs ${INSTALL_PKGS} \
        gcc \
        g++ \
        make \
        zlib-devel \
        sqlite-devel \
        openssl \
        openssl-devel && \
    rpm -V ${INSTALL_PKGS} && \
    gem install rails sqlite3 && \
    sudo chmod -R 777 /opt/rh/rh-ruby25 && \
    sudo curl -sS --location https://rpm.nodesource.com/setup_8.x | sudo bash - && \
    sudo yum install -y -d 1 \
        nodejs && \
    yum clean all -y && \
    sudo wget -qO- "https://mirror.openshift.com/pub/openshift-v3/clients/${OC_VERSION}/linux/oc.tar.gz" | sudo tar xvz -C /usr/local/bin
USER user

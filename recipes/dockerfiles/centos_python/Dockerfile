FROM registry.centos.org/che-stacks/centos-stack-base:latest
ENV PATH=/opt/rh/rh-python36/root/usr/bin${PATH:+:${PATH}} \
    LD_LIBRARY_PATH=/opt/rh/rh-python36/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
    MANPATH=/opt/rh/rh-python36/root/usr/share/man:$MANPATH \
    PKG_CONFIG_PATH=/opt/rh/rh-python36/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} \
    XDG_DATA_DIRS="/opt/rh/rh-python36/root/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" \
    OC_VERSION=3.9.38
RUN sudo yum update -y && \
    sudo yum install rh-python36 -y && \
    sudo yum clean all
USER root
RUN pip install --upgrade pip && \
    pip install --no-cache-dir virtualenv && \
    pip install --upgrade setuptools && \
    pip install 'python-language-server[all]' && \
    sudo wget -qO- "https://mirror.openshift.com/pub/openshift-v3/clients/${OC_VERSION}/linux/oc.tar.gz" | sudo tar xvz -C /usr/local/bin
USER user

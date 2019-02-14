FROM registry.centos.org/che-stacks/centos-stack-base

EXPOSE 1337 3000 4200 5000 9000 8003
LABEL che:server:8003:ref=angular che:server:8003:protocol=http che:server:3000:ref=node-3000 che:server:3000:protocol=http che:server:9000:ref=node-9000 che:server:9000:protocol=http

# Install general dependencies
RUN curl -sL https://rpm.nodesource.com/setup_11.x | sudo bash -
RUN sudo yum update -y -d 1 && \
    sudo yum downgrade -y audit-libs audit && \
    sudo yum install -y -d 1 \
      bzip2 \
      rh-git29-git && \
    sudo yum install -y -d 1 \
      nodejs && \
    sudo yum clean all -y && \
    sudo rm -rf /var/cache/yum

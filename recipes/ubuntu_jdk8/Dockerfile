FROM eclipse/ubuntu_jdk8:latest

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

# Give write access to /home/user for 
# users with an arbitrary UID 
RUN sudo chgrp -R 0 /home/user \
  && sudo chmod -R g+rwX /home/user \
  && sudo chgrp -R 0 /etc/passwd \
  && sudo chmod -R g+rwX /etc/passwd \
  && sudo chgrp -R 0 /etc/group \
  && sudo chmod -R g+rwX /etc/group
  
# Generate passwd.template
RUN cat /etc/passwd | \
    sed s#user:x.*#user:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/bash#g \
    > /home/user/passwd.template

# Generate group.template
RUN cat /etc/group | \
    sed s#root:x:0:#root:x:0,\${USER_ID}:#g \
    > /home/user/group.template

ENV HOME /home/user

# Overwride entrypoint
COPY ["entrypoint.sh","/home/user/entrypoint.sh"]

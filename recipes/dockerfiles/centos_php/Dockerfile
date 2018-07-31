FROM registry.centos.org/che-stacks/centos-stack-base:latest
ENV PHP_LS_VERSION=5.4.1 \
    OC_VERSION=3.9.38
RUN sudo yum install -y epel-release http://rpms.remirepo.net/enterprise/remi-release-7.rpm  \
    sudo yum-utils && \
    sudo yum-config-manager --enable remi-php70 && \
    sudo yum install -y \
        rpmdevtools \
        php-bcmath \
        php-cli \
        php-fpm \
        php-mysqlnd \
        php-mssql \
        php-xml \
        php-pgsql \
        php-gd \
        php-mcrypt \
        php-ldap \
        php-imap \
        php-soap \
        php-tidy \
        php-mbstring \
        php-opcache \
        php-pdo \
        php-pecl-apcu \
        php-pecl-apcu-bc \
        php-pecl-geoip \
        php-pecl-igbinary \
        php-pecl-imagick \
        php-pecl-redis \
        unzip \
        httpd && \
        sudo yum --enablerepo=epel install -y fcgi && \
        sudo yum clean all && \
        sudo sed -i 's/\/var\/www\/html/\/projects/g'  /etc/httpd/conf/httpd.conf && \
        sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf && \
        sudo sed -i 's/None/All/g' /etc/httpd/conf/httpd.conf && \
        sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf && \
        echo "ServerName localhost" | sudo tee -a /etc/httpd/conf/httpd.conf && \
        for f in "/var/log/httpd" "/etc/httpd" "/run/httpd"; do \
            sudo chgrp -R 0 ${f} && \
            sudo chmod -R g+rwX ${f}; \
          done && \
        sudo rm /etc/httpd/conf.d/welcome.conf && \
        sudo sh -c 'echo -e "; configuration for php ZendDebugger module\n; priority=90\nzend_extension=ZendDebugger.so" > /etc/php.d/zenddebugger.ini'

# since http://repos.zend.com/zend-server/9.0.2/rpm_apache2.4/x86_64/zend-server-php-7.0-common-9.0.2-372.x86_64.rpm is often down,
# it is safer to ADD the file that is available in the dockerfiles repo rather than remotely
ADD ZendDebugger.so /usr/lib64/php/modules

USER root
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir -p ${HOME}/.composer && \
    chown -R user ${HOME}/.composer
USER user

# install PHP Language Server
RUN mkdir -p ${HOME}/che/ls-php/php-language-server && \
    cd ${HOME}/che/ls-php/php-language-server && \
    composer require jetbrains/phpstorm-stubs:dev-master && \
    composer require felixfbecker/language-server:${PHP_LS_VERSION} && \
    composer run-script --working-dir=vendor/felixfbecker/language-server parse-stubs && \
    mv  vendor/* . && \
    rm -rf vendor && \
    sudo chgrp -R 0 ${HOME} && \
    sudo chmod -R g+rwX ${HOME} && \
    sudo wget -qO- "https://mirror.openshift.com/pub/openshift-v3/clients/${OC_VERSION}/linux/oc.tar.gz" | sudo tar xvz -C /usr/local/bin


CMD echo "apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin" >> /etc/passwd && \
    echo "apache:x:48:" >> /etc/group && \
    tail -f /dev/null

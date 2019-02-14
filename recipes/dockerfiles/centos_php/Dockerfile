# Copyright (c) 2012-2018 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

FROM registry.centos.org/che-stacks/centos-stack-base:latest
ENV PHP_LS_VERSION=5.4.1 \
    OC_VERSION=3.9.38
USER root
RUN yum install -y -d 1 epel-release http://rpms.remirepo.net/enterprise/remi-release-7.rpm  \
    yum-utils && \
    yum-config-manager --enable remi-php71 && \
    yum install -y -d 1 \
        rpmdevtools \
        php \
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
        yum --enablerepo=epel install -y fcgi && \
        yum clean all && \
        sed -i 's/\/var\/www\/html/\/projects/g'  /etc/httpd/conf/httpd.conf && \
        sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf && \
        sed -i 's/None/All/g' /etc/httpd/conf/httpd.conf && \
        sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf && \
        echo "ServerName localhost" |  tee -a /etc/httpd/conf/httpd.conf && \
        for f in "/var/log/httpd" "/etc/httpd" "/run/httpd"; do \
            chgrp -R 0 ${f} && \
            chmod -R g+rwX ${f}; \
          done && \
        rm /etc/httpd/conf.d/welcome.conf && \
        curl -sS http://repos.zend.com/zend-server/9.1.4/rpm_apache2.4/x86_64/zend-server-php-7.1-common-9.1.4-331.x86_64.rpm -o ~/zend.rpm && \
        rpmdev-extract -C ~ ~/zend.rpm && \
        sudo cp ~/zend-server-php-7.1-common-9.1.4-331.x86_64/usr/local/zend/lib/debugger/php-7.1.x/ZendDebugger.so /usr/lib64/php/modules && \
        rm ~/zend.rpm && \
        rm -rf ~/zend-server-php-7.1-common-9.1.4-331.x86_64 && \
        sh -c 'echo -e "; configuration for php ZendDebugger module\n; priority=90\nzend_extension=ZendDebugger.so" > /etc/php.d/zenddebugger.ini' && \
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
        mkdir -p ${HOME}/.composer && \
        chown -R user ${HOME}/.composer && \
        mkdir -p ${HOME}/che/ls-php/php-language-server && \
        cd ${HOME}/che/ls-php/php-language-server && \
        composer require jetbrains/phpstorm-stubs:dev-master && \
        composer require felixfbecker/language-server:${PHP_LS_VERSION} && \
        composer run-script --working-dir=vendor/felixfbecker/language-server parse-stubs && \
        mv  vendor/* . && \
        rm -rf vendor && \
        chgrp -R 0 ${HOME} && \
        chmod -R g+rwX ${HOME} && \
        wget -qO- "https://mirror.openshift.com/pub/openshift-v3/clients/${OC_VERSION}/linux/oc.tar.gz" |  tar xvz -C /usr/local/bin

USER user
CMD echo "apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin" >> /etc/passwd && \
    echo "apache:x:48:" >> /etc/group && \
    tail -f /dev/null

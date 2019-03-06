FROM ubuntu:18.04

MAINTAINER "Thaweesak Chusri" <t.chusri@gmail.com>

ENV TZ=Asia/Bangkok
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Upgrade
RUN apt-get update -y
RUN apt-get upgrade -y

RUN mkdir -p /data
VOLUME ["/data"]

RUN apt-get update -y && apt-get install -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository -y -u ppa:ondrej/php

# Install PHP-FPM and popular/laravel required extensions
RUN DEBIAN_FRONTEND=noninteractive && apt-get update -y && apt-get install -y \
    language-pack-th-base \
    git \
    # Install apache
    apache2 \
    # Install php 7.2
    libapache2-mod-php7.3 \
    zip \
    unzip \
    curl \
    git \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-mbstring \
    php7.3-curl \
    php7.3-gd \
    php7.3-intl \
    php7.3-imagick \
    php7.3-imap \
    php7.3-memcache \
    php7.3-pspell \
    php7.3-recode \
    php7.3-sqlite3 \
    php7.3-tidy \
    php7.3-xmlrpc \
    php7.3-xsl \
    php7.3-mbstring \
    php7.3-gettext \
    php7.3-mongodb \
    php7.3-ldap \
    vim 

# Configure PHP-FPM
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Bangkok/" /etc/php/7.3/fpm/php.ini
# RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.3/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.3/fpm/php.ini
# RUN echo "xdebug.max_nesting_level=500" > /etc/php5/mods-available/xdebug.ini
# sed -i "s/display_errors = Off/display_errors = stderr/" /etc/php/7.3/fpm/php.ini && \
# sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/" /etc/php/7.3/fpm/php.ini && \
# sed -i "s/;opcache.enable=0/opcache.enable=0/" /etc/php/7.3/fpm/php.ini && \
# sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
# sed -i '/^listen = /clisten = 9000' /etc/php5/fpm/pool.d/www.conf && \
# sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php5/fpm/pool.d/www.conf && \
# sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php5/fpm/pool.d/www.conf && \
# sed -i '/^;env\[TEMP\] = .*/aenv[DB_PORT_3306_TCP_ADDR] = $DB_PORT_3306_TCP_ADDR' /etc/php5/fpm/pool.d/www.conf

RUN phpenmod mbstring

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 th_TH.UTF-8

# Configure apache for default
RUN a2enmod rewrite expires
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername
# Configure vhost for default
COPY default /etc/apache2/sites-available/
RUN a2dissite 000-default
RUN a2ensite default

VOLUME ["/data"]

# PORTS
EXPOSE 80
EXPOSE 443
EXPOSE 9000

WORKDIR /data

CMD ["apachectl -D FOREGROUND"]

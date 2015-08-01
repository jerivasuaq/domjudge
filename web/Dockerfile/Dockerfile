FROM php:5.6-apache

COPY apache2.conf /etc/apache2/apache2.conf
COPY php.ini /usr/local/etc/php/


RUN apt-get update && apt-get -y upgrade && apt-get install -y rsync curl apt-transport-https && rm -r /var/lib/apt/lists/*
RUN a2enmod rewrite proxy_http
# install the PHP extensions we need
RUN apt-get update && \
apt-get install -y libpng12-dev libapache2-mod-proxy-html && \
rm -rf /var/lib/apt/lists/* && \
docker-php-ext-install gd && \
apt-get purge --auto-remove -y libpng12-dev

RUN docker-php-ext-install mysqli 

VOLUME /var/www/html

RUN curl -o - https://www.domjudge.org/repokey.asc | apt-key add -

RUN \
    echo "deb     https://domjudge.org/debian unstable/" > /etc/apt/sources.list.d/domjudge.list && \
    echo "deb-src https://domjudge.org/debian unstable/" >> /etc/apt/sources.list.d/domjudge.list && \
    apt-get install apt-transport-https && \
    apt-get update && \
    apt-get install -s 'domjudge*'

COPY apache.conf /etc/domjudge/apache.conf
COPY domserver.dbconfig.php /etc/domjudge/domserver.dbconfig.php
COPY restapi.secret  /etc/domjudge/restapi.secret


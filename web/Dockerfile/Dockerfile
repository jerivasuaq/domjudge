#FROM php:5.6-apache
FROM debian:latest


RUN apt-get update && apt-get -y upgrade && apt-get install -y rsync curl apt-transport-https debconf-utils && rm -r /var/lib/apt/lists/*

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y \
    rsync curl apt-transport-https debconf-utils wget \
    gcc g++ make zip unzip \
    apache2 php5 php5-cli libapache2-mod-php5 \
    php5-curl php5-mysql php5-json \
    bsdmainutils ntp \
    libboost-regex-dev libgmp3-dev linuxdoc-tools linuxdoc-tools-text \
    groff texlive-latex-recommended texlive-latex-extra \
    texlive-fonts-recommended texlive-lang-dutch

RUN curl -o - https://www.domjudge.org/repokey.asc | apt-key add -

RUN \
    apt-get update && \
    apt-get install -y  \
    apt-transport-https \
    beep dbconfig-common libaio1 \
    libdbd-mysql-perl libdbi-perl libgd3 libhtml-template-perl libjs-sphinxdoc \
    libjs-underscore libmcrypt4 libterm-readkey-perl libvpx1 libwrap0 \
    mysql-client mysql-client-5.5 php-gettext php-tcpdf php5-gd php5-mcrypt\
    tcpd

# RUN echo "domjudge-domserver domjudge-domserver/dbconfig-install boolean false" | debconf-set-selections

COPY debconf.selections /tmp/debconf.selections
RUN cat /tmp/debconf.selections | debconf-set-selections

RUN \
    echo "deb     https://domjudge.org/debian unstable/ " > /etc/apt/sources.list.d/domjudge.list && \
    echo "deb-src https://domjudge.org/debian unstable/ " >> /etc/apt/sources.list.d/domjudge.list && \
    apt-get update && \
    apt-cache search  domjudge && \
    apt-get install -y --no-install-recommends  domjudge-common domjudge-domserver

COPY domserver.dbconfig.php /etc/domjudge/domserver.dbconfig.php

RUN \
    chown -R www-data:www-data /etc/domjudge/*.php 


VOLUME /var/www/html

COPY start_foreground.sh /start_foreground.sh

ENTRYPOINT ["/start_foreground.sh"]


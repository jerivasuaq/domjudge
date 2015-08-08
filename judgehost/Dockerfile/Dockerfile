FROM debian:latest


RUN apt-get update && apt-get -y upgrade && apt-get install -y rsync curl apt-transport-https debconf-utils && rm -r /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    make sudo debootstrap php5-cli php5-curl php5-json procps \
    gcc g++ 

RUN curl -o - https://www.domjudge.org/repokey.asc | apt-key add -

# RUN \
#     apt-get update && \
#     apt-get install -y  \
#     apt-transport-https \
#     beep dbconfig-common libaio1 \
#     libdbd-mysql-perl libdbi-perl libgd3 libhtml-template-perl libjs-sphinxdoc \
#     libjs-underscore libmcrypt4 libterm-readkey-perl libvpx1 libwrap0 \
#     mysql-client mysql-client-5.5 php-gettext php-tcpdf php5-gd php5-mcrypt\
#     tcpd
 
COPY debconf.selections /tmp/debconf.selections
RUN cat /tmp/debconf.selections | debconf-set-selections

RUN \
    echo "deb     https://domjudge.org/debian unstable/" > /etc/apt/sources.list.d/domjudge.list && \
    echo "deb-src https://domjudge.org/debian unstable/" >> /etc/apt/sources.list.d/domjudge.list && \
    apt-get update && \
    apt-get install -y domjudge-judgehost && \
    dj_make_chroot

COPY restapi.secret  /etc/domjudge/restapi.secret

#ENTRYPOINT ["/usr/sbin/judgedaemon"]
#USER domjudge-run



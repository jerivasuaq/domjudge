FROM debian:latest

RUN apt-get update && apt-get -y upgrade && apt-get install -y wget rsync curl apt-transport-https debconf-utils build-essential git vim 

RUN apt-get install -y lsb-release mlocate

RUN rm -r /var/lib/apt/lists/*

# RUN apt-get update && apt-get -y upgrade && \
#     apt-get install -y \
#     rsync curl apt-transport-https debconf-utils wget \
#     gcc g++ make zip unzip \
#     apache2 php5 php5-cli libapache2-mod-php5 \
#     php5-curl php5-mysql php5-json \
#     bsdmainutils ntp \
#     libboost-regex-dev libgmp3-dev linuxdoc-tools linuxdoc-tools-text \
#     groff texlive-latex-recommended texlive-latex-extra \
#     texlive-fonts-recommended texlive-lang-dutch
# 
# RUN apt-get update && apt-get -y upgrade && \
#     apt-get install -y \
#         vim wget aptitude libcurl3-dev libjsoncpp-dev libboost-all-dev libgmp-dev
# 

# RUN wget https://www.domjudge.org/releases/domjudge-4.0.6.tar.gz && \
#     tar xzvf domjudge-4.0.6.tar.gz && \
#     cd domjudge-4.0.6 && \
#     ./configure && \
#     make judgehost && \
#     make install-judgehost 
# 

COPY install.sh /tmp/install.sh
COPY extra-files.tgz /tmp/extra-files.tgz
RUN /tmp/install.sh





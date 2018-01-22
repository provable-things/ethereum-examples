FROM ubuntu:16.04
MAINTAINER Oraclize "info@oraclize.it"

RUN apt-get update \
    && apt-get install -y wget gnupg2 python3-setuptools python3-pyqt5 python3-pip jq
RUN wget https://download.electrum.org/3.0.5/Electrum-3.0.5.tar.gz \
    && /usr/bin/wget https://download.electrum.org/3.0.5/Electrum-3.0.5.tar.gz.asc \
    && /usr/bin/gpg2 --recv-key 0x2bd5824b7f9470e6;
RUN if [ $(/usr/bin/gpg2 --logger-fd 1 --status-fd 1 --always-trust --verify Electrum-3.0.5.tar.gz.asc Electrum-3.0.5.tar.gz | grep "GOODSIG 2BD5824B7F9470E6" | wc -l) -ne 1 ]; then exit 2; fi;
RUN /usr/bin/pip3 install Electrum-3.0.5.tar.gz
CMD /usr/local/bin/electrum daemon start \
   && /usr/local/bin/electrum getaddressbalance "$ARG0" | jq .confirmed \
   && exit 0; 

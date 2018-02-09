FROM ubuntu:14.04
MAINTAINER Oraclize "info@oraclize.it"

RUN apt-get update && apt-get -y install python-minimal
COPY concat.py /tmp/
CMD /usr/bin/python /tmp/concat.py 
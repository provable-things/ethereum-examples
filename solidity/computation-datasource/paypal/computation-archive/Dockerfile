FROM ubuntu:16.04
MAINTAINER Oraclize "info@oraclize.it"

RUN apt-get update && apt-get -y install python libffi6 libffi-dev python-dev python-pip libssl-dev wget build-essential
RUN pip install paypalrestsdk \
    && pip install flask \
    && pip install pyOpenSSL
COPY pay.py /tmp/
ENV FLASK_APP="/tmp/pay.py"
CMD /usr/bin/wget --no-check-certificate -O /dev/null -q "$ARG3" > /dev/null 2> /dev/null; /usr/bin/python -m flask run --host=0.0.0.0 --port 8090 > /dev/null 2> /dev/null && cat /tmp/output

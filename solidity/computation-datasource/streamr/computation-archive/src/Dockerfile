FROM mhart/alpine-node:8
MAINTAINER Oraclize "info@oraclize.it"

COPY index.js package.json /tmp/
WORKDIR /tmp/
RUN yarn install
CMD node index.js $ARG0

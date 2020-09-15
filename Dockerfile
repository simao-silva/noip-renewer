FROM debian:10-slim

ARG DEBIAN_FRONTEND=noninteractive

ARG OPTIONS="--assume-yes --no-install-recommends --no-install-suggests"

RUN apt-get update && \
    apt-get install ${OPTIONS} chromium chromium-driver python3-pip && \
    pip3 install selenium && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ADD renew.py .

ENTRYPOINT /usr/bin/python3 renew.py

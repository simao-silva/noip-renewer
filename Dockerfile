FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /home

RUN echo "Package: *\n\
Pin: release o=LP-PPA-xalt7x-chromium-deb-vaapi\n\
Pin-Priority: 1337\n" >> /etc/apt/preferences.d/pin-xalt7x-chromium-deb-vaapi

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:xalt7x/chromium-deb-vaapi -y && \
    apt-get install -y --no-install-recommends chromium-browser chromium-chromedriver nano python3 python3-pip && \
    pip3 install selenium && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ADD renew.py .

ENTRYPOINT /usr/bin/python3 renew.py

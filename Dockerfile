FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN echo "Package: *\n\
Pin: release o=LP-PPA-xalt7x-chromium-deb-vaapi\n\
Pin-Priority: 1337\n" > /etc/apt/preferences.d/pin-xalt7x-chromium-deb-vaapi

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:xalt7x/chromium-deb-vaapi -y && \
    apt-get install -y --no-install-recommends chromium-browser chromium-chromedriver nano python3 python3-pip  && \
   rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN pip3 install selenium    

WORKDIR /home

CMD /bin/bash


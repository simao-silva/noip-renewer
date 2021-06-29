ARG PYTHON_VERSION
ARG ALPINE_VERSION

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

RUN apk add --no-cache chromium chromium-chromedriver && \
    pip3 install --no-cache-dir selenium && \
    rm -rf /var/cache/apk/* /tmp/*

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]


FROM python:3.9.1-alpine3.13

RUN apk add --no-cache chromium chromium-chromedriver && \
    pip3 install --no-cache-dir selenium && \
    rm -rf /var/cache/*

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]

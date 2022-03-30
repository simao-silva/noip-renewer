FROM python:3.10.4-alpine@sha256:9316f0d151250a0b5a6c6bc26ed11f7e1cb29e856fa0da48fa9d084a3c67d46d

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.4-alpine@sha256:9316f0d151250a0b5a6c6bc26ed11f7e1cb29e856fa0da48fa9d084a3c67d46d

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
FROM python:3.10.2-alpine@sha256:90f7e61ccd9c5729a4bb9e0074bb3ed7a107f42c5fb401065cdb2a33f549e206

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.2-alpine@sha256:90f7e61ccd9c5729a4bb9e0074bb3ed7a107f42c5fb401065cdb2a33f549e206

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
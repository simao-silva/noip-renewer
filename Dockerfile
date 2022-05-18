FROM python:3.10.4-alpine@sha256:442f71ac85f5c60ca0397f9e38710ba449e0923a8e6d173040384a4b6a9b7a0e

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.4-alpine@sha256:442f71ac85f5c60ca0397f9e38710ba449e0923a8e6d173040384a4b6a9b7a0e

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
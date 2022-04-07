FROM python:3.10.4-alpine@sha256:7cdad925ec82b96682f50ae3ac22f81b0b5ead32ae768f75c5d3b9a21e8d25bd

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.4-alpine@sha256:7cdad925ec82b96682f50ae3ac22f81b0b5ead32ae768f75c5d3b9a21e8d25bd

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
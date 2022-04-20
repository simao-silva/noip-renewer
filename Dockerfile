FROM python:3.10.4-alpine@sha256:e772f40012c11db0c2fd0e7c812a6c467c013c78fcb6cb735660992a8b215db1

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.4-alpine@sha256:e772f40012c11db0c2fd0e7c812a6c467c013c78fcb6cb735660992a8b215db1

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
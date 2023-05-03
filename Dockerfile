FROM python:3.11.3-alpine@sha256:06a3f7b12a56ed051612416d3083814e145afc7fc3fc52a67aeffa348a20383c

ARG PIP_VERSION

COPY requirements.txt /requirements.txt

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user -r /requirements.txt


FROM python:3.11.3-alpine@sha256:06a3f7b12a56ed051612416d3083814e145afc7fc3fc52a67aeffa348a20383c

RUN apk add --no-cache firefox && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing geckodriver && \
    # Added patched versions from Trivy scan
    apk upgrade libcrypto3 libssl3 && \
    pip install --no-cache-dir "setuptools>=65.5.1" && \
    rm -rf /var/cache/apk/* /tmp/*

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

COPY renew.py .

ENTRYPOINT ["python3", "renew.py"]

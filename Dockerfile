FROM python:3.11.2-alpine@sha256:4b4078a3ab81edc2f5725cd42b065beaeeb4f9be3b4b1e3b4cf11dd6ae9720d3

ARG PIP_VERSION

COPY requirements.txt /requirements.txt

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user -r /requirements.txt


FROM python:3.11.2-alpine@sha256:4b4078a3ab81edc2f5725cd42b065beaeeb4f9be3b4b1e3b4cf11dd6ae9720d3

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

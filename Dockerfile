FROM python:3.11.1-alpine@sha256:d8b0703ce84fe5a52d485f212e9d852bcdb8606798064f5f21af57325a7cf73f

ARG PIP_VERSION

COPY requirements.txt /requirements.txt

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user -r /requirements.txt


FROM python:3.11.1-alpine@sha256:d8b0703ce84fe5a52d485f212e9d852bcdb8606798064f5f21af57325a7cf73f

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

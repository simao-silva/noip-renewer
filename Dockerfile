FROM python:3.11.0-alpine@sha256:201cf834ec9cfb05e73228d569af2603a7ffb3d287f1a44b56149201345bfe04

ARG PIP_VERSION

COPY requirements.txt /requirements.txt

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user -r /requirements.txt


FROM python:3.11.0-alpine@sha256:201cf834ec9cfb05e73228d569af2603a7ffb3d287f1a44b56149201345bfe04

RUN apk add --no-cache firefox && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing geckodriver && \
    # Added patched versions from Trivy scan
    apk upgrade krb5-libs && \
    rm -rf /var/cache/apk/* /tmp/*

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

COPY renew.py .

ENTRYPOINT ["python3", "renew.py"]

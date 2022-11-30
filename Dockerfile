FROM python:3.11.0-alpine@sha256:a651419779f8b2a0dbd6c46dd238d7309b01ec65164bcce51a680fc868415eea

ARG PIP_VERSION

COPY requirements.txt /requirements.txt

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user -r /requirements.txt


FROM python:3.11.0-alpine@sha256:a651419779f8b2a0dbd6c46dd238d7309b01ec65164bcce51a680fc868415eea

RUN apk add --no-cache firefox && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing geckodriver && \
    # Added patched versions from Trivy scan
    apk upgrade krb5-libs && \
    rm -rf /var/cache/apk/* /tmp/*

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

COPY renew.py .

ENTRYPOINT ["python3", "renew.py"]

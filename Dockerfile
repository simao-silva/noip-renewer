FROM python:3.12.0-alpine@sha256:4fb2cdab707593459d021cbc776add5fe4642708ae1f0831a1df358fa637fc4c

ARG PIP_VERSION

COPY requirements.txt /requirements.txt

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user -r /requirements.txt


FROM python:3.12.0-alpine@sha256:4fb2cdab707593459d021cbc776add5fe4642708ae1f0831a1df358fa637fc4c

RUN apk add --no-cache firefox && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing geckodriver && \
    ln -s /usr/bin/geckodriver /usr/local/bin/geckodriver && \
    rm -rf /var/cache/apk/* /tmp/*

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

COPY renew.py .

ENTRYPOINT ["python3", "renew.py"]

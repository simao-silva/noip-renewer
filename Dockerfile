ARG PYTHON_VERSION
ARG ALPINE_VERSION

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS compile-image

ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir --user selenium==$SELENIUM_VERSION



FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=compile-image /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]


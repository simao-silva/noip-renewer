FROM python:3.10.4-alpine@sha256:f4c1b7853b1513eb2f551597e2929b66374ade28465e7d79ac9e099ccecdfeec

ARG PIP_VERSION
ARG SELENIUM_VERSION
ARG GOOGLETRANS_VERSION
ARG REQUESTS_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION" googletrans=="$GOOGLETRANS_VERSION" requests=="$REQUESTS_VERSION"



FROM python:3.10.4-alpine@sha256:f4c1b7853b1513eb2f551597e2929b66374ade28465e7d79ac9e099ccecdfeec

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]

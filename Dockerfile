FROM python:3.10.3-alpine@sha256:9b0080754968f1effee7b17e8cd28a32261c9bd472fa845d4b55c1d66f3a9be7

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.3-alpine@sha256:9b0080754968f1effee7b17e8cd28a32261c9bd472fa845d4b55c1d66f3a9be7

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
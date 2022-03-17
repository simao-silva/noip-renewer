FROM python:3.10.3-alpine@sha256:3a8010ecba6de747e36f36f5de8a32d109218796188478dc2d890e1ab7224ccb

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.3-alpine@sha256:3a8010ecba6de747e36f36f5de8a32d109218796188478dc2d890e1ab7224ccb

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
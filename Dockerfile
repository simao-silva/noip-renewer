FROM python:3.10.3-alpine@sha256:d06e94b0c4bea87ba5f00bdccc60cbc92f41caf1961acb27d4efef8d0db7af10

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.3-alpine@sha256:d06e94b0c4bea87ba5f00bdccc60cbc92f41caf1961acb27d4efef8d0db7af10

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
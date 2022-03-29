FROM python:3.10.4-alpine@sha256:ebcb1714a8f5abbf0b03262e518ca0453131cf720ea0a0f85e9bf3bfd7c1d53d

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.4-alpine@sha256:ebcb1714a8f5abbf0b03262e518ca0453131cf720ea0a0f85e9bf3bfd7c1d53d

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
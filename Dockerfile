FROM python:3.10.3-alpine@sha256:1c113b4ca05ce0ffcbe41cb24fab4d4ca1ddb1a2b87c6284e38fafc4c769ad22

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.3-alpine@sha256:1c113b4ca05ce0ffcbe41cb24fab4d4ca1ddb1a2b87c6284e38fafc4c769ad22

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
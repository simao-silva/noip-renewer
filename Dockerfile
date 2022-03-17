FROM python:3.10.3-alpine@sha256:0b1a392301a35d823d9df612d068e8c8c8837530a57a4dfa356835aafb8ab82e

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.3-alpine@sha256:0b1a392301a35d823d9df612d068e8c8c8837530a57a4dfa356835aafb8ab82e

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
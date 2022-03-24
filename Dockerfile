FROM python:3.10.3-alpine@sha256:cef1da7133de6dbde6c0e253dcd5b2b3085ed3d9c49392f76c07a973df3fa0f7

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.3-alpine@sha256:cef1da7133de6dbde6c0e253dcd5b2b3085ed3d9c49392f76c07a973df3fa0f7

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
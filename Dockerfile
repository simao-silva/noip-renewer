FROM python:3.11.0-alpine@sha256:92c847b1056058dea07d35af81d68ac7f652c6a4ca36072e2f52b89d893fa47d

ARG PIP_VERSION
ARG SELENIUM_VERSION
ARG GOOGLETRANS_VERSION
ARG REQUESTS_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION" googletrans=="$GOOGLETRANS_VERSION" requests=="$REQUESTS_VERSION"



FROM python:3.11.0-alpine@sha256:92c847b1056058dea07d35af81d68ac7f652c6a4ca36072e2f52b89d893fa47d

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]

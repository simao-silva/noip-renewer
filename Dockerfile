FROM python:3.10.4-alpine@sha256:fdea1877b9b341639ce5fc436b8dddad77e0872570c6848695dbabf701b296be

ARG PIP_VERSION
ARG SELENIUM_VERSION

RUN apk add --no-cache gcc libc-dev libffi-dev && \
    pip install --no-cache-dir pip=="$PIP_VERSION" && \
    pip install --no-cache-dir --user selenium=="$SELENIUM_VERSION"



FROM python:3.10.4-alpine@sha256:fdea1877b9b341639ce5fc436b8dddad77e0872570c6848695dbabf701b296be

RUN apk add --no-cache chromium chromium-chromedriver && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/doc

COPY --from=0 /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

ADD renew.py .

ENTRYPOINT ["python3", "renew.py"]
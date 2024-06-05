FROM python:3.12.3-alpine@sha256:d696c999babcff2d6194727e5c36908e7741aa530e6ed0d8e2fb4b6cfb7be43d AS builder

# Prevent Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE 1

# Keep Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED 1

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="24.0"

# Set the working directory
WORKDIR /app

# Add requirements file
COPY requirements.txt .

# Install requirements
RUN python3 -m venv ${VIRTUAL_ENV} && \
    pip install --no-cache-dir --upgrade pip=="${PIP_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt



FROM python:3.12.3-alpine@sha256:d696c999babcff2d6194727e5c36908e7741aa530e6ed0d8e2fb4b6cfb7be43d

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="24.0"

# renovate: datasource=repology depName=alpine_3_20/firefox versioning=loose
ARG FIREFOX_VERSION="126.0-r0"

# renovate: datasource=repology depName=alpine_3_20/font-noto versioning=loose
ARG FONT_MOTO_VERSION="23.7.1-r0"

# renovate: datasource=repology depName=alpine_edge/geckodriver versioning=loose
ARG GECKODRIVER_VERSION="0.34.0-r0"

# renovate: datasource=repology depName=alpine_3_20/openssl versioning=loose
ARG OPENSSL_VERSION="3.3.0-r2"

# renovate: datasource=repology depName=alpine_3_20/expat versioning=loose
ARG EXPAT_VERSION="2.6.2-r0"

RUN apk add --no-cache firefox="${FIREFOX_VERSION}" font-noto=="${FONT_MOTO_VERSION}" && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community geckodriver="${GECKODRIVER_VERSION}" && \
    ln -s /usr/bin/geckodriver /usr/local/bin/geckodriver && \
    rm -rf /var/cache/apk/* /tmp/*

# Fix vulnerabilities reported by Trivy
RUN apk add --no-cache libcrypto3="${OPENSSL_VERSION}" libssl3="${OPENSSL_VERSION}" libexpat="${EXPAT_VERSION}" && \
    /usr/local/bin/pip install --upgrade pip=="${PIP_VERSION}"

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Copy dependencies from previous stage
COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV

# Set the working directory
WORKDIR /app

# Copy and set the entrypoint bash script
COPY renew.py .
ENTRYPOINT ["python3", "renew.py"]

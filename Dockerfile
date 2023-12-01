FROM python:3.12.0-alpine@sha256:85eaef27f58a5fd6074f5353449156bc5651131d17018864c275d5c7b960ca9a AS builder

# Prevent Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE 1

# Keep Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED 1

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Set PIP version from build args
ARG PIP_VERSION

# Set the working directory
WORKDIR /app

# Add requirements file
COPY requirements.txt .

# Install requirements
RUN python3 -m venv $VIRTUAL_ENV && \
    pip install --no-cache-dir --upgrade pip=="${PIP_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt



FROM python:3.12.0-alpine@sha256:85eaef27f58a5fd6074f5353449156bc5651131d17018864c275d5c7b960ca9a

# renovate: datasource=repology depName=alpine_3_18/firefox versioning=loose
ARG FIREFOX_VERSION="119.0-r0"

# renovate: datasource=repology depName=alpine_edge/geckodriver versioning=loose
ARG GECKODRIVER_VERSION="0.33.0-r1"

# renovate: datasource=repology depName=alpine_3_18/openssl versioning=loose
ARG OPENSSL_VERSION="3.1.4-r1"

RUN apk add --no-cache firefox="${FIREFOX_VERSION}" && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing geckodriver="${GECKODRIVER_VERSION}" && \
    ln -s /usr/bin/geckodriver /usr/local/bin/geckodriver && \
    rm -rf /var/cache/apk/* /tmp/*

# Fix vulnerabilities reported by Trivy
ARG PIP_VERSION
RUN apk add --no-cache libcrypto3="${OPENSSL_VERSION}" libssl3="${OPENSSL_VERSION}" && \
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

FROM python:3.13.2-alpine@sha256:2c39ec94d4a87a074cced458da07865b427c5767e18f86e0fef59ce874d5c2e3 AS builder

# Prevent Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Keep Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED=1

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="25.0.1"

# Set the working directory
WORKDIR /app

# Add requirements file
COPY requirements.txt .

# Install requirements
RUN python3 -m venv ${VIRTUAL_ENV} && \
    pip install --no-cache-dir --upgrade pip=="${PIP_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt



FROM python:3.13.2-alpine@sha256:2c39ec94d4a87a074cced458da07865b427c5767e18f86e0fef59ce874d5c2e3

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="25.0.1"

# renovate: datasource=repology depName=alpine_3_21/firefox versioning=loose
ARG FIREFOX_VERSION="135.0-r0"

# renovate: datasource=repology depName=alpine_3_21/font-noto versioning=loose
ARG FONT_MOTO_VERSION="24.7.1-r0"

# renovate: datasource=repology depName=alpine_edge/geckodriver versioning=loose
ARG GECKODRIVER_VERSION="0.35.0-r0"

# renovate: datasource=repology depName=alpine_3_21/openssl versioning=loose
ARG OPENSSL_VERSION="3.3.3-r0"

# renovate: datasource=repology depName=alpine_3_21/expat versioning=loose
ARG EXPAT_VERSION="2.6.4-r0"

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

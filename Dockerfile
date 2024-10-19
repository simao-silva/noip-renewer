FROM python:3.13.0-alpine@sha256:92e0e7f0e119e631e5d08a77bab4e2f35a93c727057cae6528d58880f8e77f6e AS builder

# Prevent Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Keep Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED=1

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="24.2"

# Set the working directory
WORKDIR /app

# Add requirements file
COPY requirements.txt .

# Install requirements
RUN python3 -m venv ${VIRTUAL_ENV} && \
    pip install --no-cache-dir --upgrade pip=="${PIP_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt



FROM python:3.13.0-alpine@sha256:92e0e7f0e119e631e5d08a77bab4e2f35a93c727057cae6528d58880f8e77f6e

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="24.2"

# renovate: datasource=repology depName=alpine_3_20/firefox versioning=loose
ARG FIREFOX_VERSION="131.0.2-r0"

# renovate: datasource=repology depName=alpine_3_20/font-noto versioning=loose
ARG FONT_MOTO_VERSION="23.7.1-r0"

# renovate: datasource=repology depName=alpine_edge/geckodriver versioning=loose
ARG GECKODRIVER_VERSION="0.35.0-r0"

# renovate: datasource=repology depName=alpine_3_20/openssl versioning=loose
ARG OPENSSL_VERSION="3.3.2-r0"

# renovate: datasource=repology depName=alpine_3_20/expat versioning=loose
ARG EXPAT_VERSION="2.6.3-r0"

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

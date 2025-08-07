FROM python:3.13.6-alpine@sha256:f196fd275fdad7287ccb4b0a85c2e402bb8c794d205cf6158909041c1ee9f38d AS builder

# Prevent Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Keep Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED=1

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="25.2"

# Set the working directory
WORKDIR /app

# Add requirements file
COPY requirements.txt .

# Install requirements
RUN python3 -m venv ${VIRTUAL_ENV} && \
    pip install --no-cache-dir --upgrade pip=="${PIP_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt



FROM python:3.13.6-alpine@sha256:f196fd275fdad7287ccb4b0a85c2e402bb8c794d205cf6158909041c1ee9f38d

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="25.2"

# renovate: datasource=repology depName=alpine_3_22/firefox versioning=loose
ARG FIREFOX_VERSION="140.0.4-r1"

# renovate: datasource=repology depName=alpine_3_22/font-noto versioning=loose
ARG FONT_MOTO_VERSION="2025.05.01-r0"

# renovate: datasource=repology depName=alpine_edge/geckodriver versioning=loose
ARG GECKODRIVER_VERSION="0.36.0-r0"

# renovate: datasource=repology depName=alpine_3_22/openssl versioning=loose
ARG OPENSSL_VERSION="3.5.1-r0"

# renovate: datasource=repology depName=alpine_3_22/expat versioning=loose
ARG EXPAT_VERSION="2.7.1-r0"

# renovate: datasource=repology depName=alpine_3_22/sqlite versioning=loose
ARG SQLITE_VERSION="3.49.2-r1"

# Install required packages and apply fixes for vulnerabilities reported by Trivy
RUN apk add --no-cache \
        firefox="${FIREFOX_VERSION}" \
        font-noto=="${FONT_MOTO_VERSION}" \
        libcrypto3="${OPENSSL_VERSION}" \
        libexpat="${EXPAT_VERSION}" \
        libssl3="${OPENSSL_VERSION}" \
        sqlite-libs="${SQLITE_VERSION}" && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community geckodriver="${GECKODRIVER_VERSION}" && \
    ln -s /usr/bin/geckodriver /usr/local/bin/geckodriver && \
    /usr/local/bin/pip install --upgrade pip=="${PIP_VERSION}" && \
    rm -rf /var/cache/apk/* /tmp/*

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

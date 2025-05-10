FROM python:3.13.3-alpine@sha256:452682e4648deafe431ad2f2391d726d7c52f0ff291be8bd4074b10379bb89ff AS builder

# Prevent Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Keep Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED=1

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="25.1.1"

# Set the working directory
WORKDIR /app

# Add requirements file
COPY requirements.txt .

# Install requirements
RUN python3 -m venv ${VIRTUAL_ENV} && \
    pip install --no-cache-dir --upgrade pip=="${PIP_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt



FROM python:3.13.3-alpine@sha256:452682e4648deafe431ad2f2391d726d7c52f0ff291be8bd4074b10379bb89ff

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="25.1.1"

# renovate: datasource=repology depName=alpine_3_21/firefox versioning=loose
ARG FIREFOX_VERSION="136.0.4-r0"

# renovate: datasource=repology depName=alpine_3_21/font-noto versioning=loose
ARG FONT_MOTO_VERSION="24.7.1-r0"

# renovate: datasource=repology depName=alpine_edge/geckodriver versioning=loose
ARG GECKODRIVER_VERSION="0.36.0-r0"

# renovate: datasource=repology depName=alpine_3_21/openssl versioning=loose
ARG OPENSSL_VERSION="3.3.3-r0"

# renovate: datasource=repology depName=alpine_3_21/expat versioning=loose
ARG EXPAT_VERSION="2.7.0-r0"

# renovate: datasource=repology depName=alpine_3_21/sqlite versioning=loose
ARG SQLITE_VERSION="3.48.0-r2"

RUN apk add --no-cache firefox="${FIREFOX_VERSION}" font-noto=="${FONT_MOTO_VERSION}" && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community geckodriver="${GECKODRIVER_VERSION}" && \
    ln -s /usr/bin/geckodriver /usr/local/bin/geckodriver && \
    rm -rf /var/cache/apk/* /tmp/*

# Fix vulnerabilities reported by Trivy
RUN apk add --no-cache libcrypto3="${OPENSSL_VERSION}" libssl3="${OPENSSL_VERSION}" libexpat="${EXPAT_VERSION}" sqlite-libs="${SQLITE_VERSION}" && \
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

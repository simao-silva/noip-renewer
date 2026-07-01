FROM python:3.14.6-alpine@sha256:26730869004e2b9c4b9ad09cab8625e81d256d1ce97e72df5520e806b1709f92 AS builder

# Prevent Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Keep Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED=1

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="26.1.2"

# Set the working directory
WORKDIR /app

# Add requirements file
COPY requirements.txt .

# Install requirements
RUN python3 -m venv ${VIRTUAL_ENV} && \
    pip install --no-cache-dir --upgrade pip=="${PIP_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt



FROM python:3.14.6-alpine@sha256:26730869004e2b9c4b9ad09cab8625e81d256d1ce97e72df5520e806b1709f92

# renovate: datasource=pypi depName=pip versioning=pep440
ARG PIP_VERSION="26.1.2"

# renovate: datasource=repology depName=alpine_3_24/firefox versioning=loose
ARG FIREFOX_VERSION="151.0.3-r0"

# renovate: datasource=repology depName=alpine_3_24/font-noto versioning=loose
ARG FONT_MOTO_VERSION="2026.06.01-r0"

# renovate: datasource=repology depName=alpine_edge/geckodriver versioning=loose
ARG GECKODRIVER_VERSION="0.37.0-r0"

# renovate: datasource=repology depName=alpine_3_24/openssl versioning=loose
ARG OPENSSL_VERSION="3.5.7-r0"

# renovate: datasource=repology depName=alpine_3_24/expat versioning=loose
ARG EXPAT_VERSION="2.8.1-r0"

# renovate: datasource=repology depName=alpine_3_24/sqlite versioning=loose
ARG SQLITE_VERSION="3.53.2-r0"

# renovate: datasource=repology depName=alpine_3_24/zlib versioning=loose
ARG ZLIB_VERSION="1.3.2-r0"

# Install required packages and apply fixes for vulnerabilities reported by Trivy
RUN apk add --no-cache \
			firefox="${FIREFOX_VERSION}" \
			font-noto=="${FONT_MOTO_VERSION}" \
			libcrypto3="${OPENSSL_VERSION}" \
			libexpat="${EXPAT_VERSION}" \
			libssl3="${OPENSSL_VERSION}" \
			sqlite-libs="${SQLITE_VERSION}" \
			zlib="${ZLIB_VERSION}" && \
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

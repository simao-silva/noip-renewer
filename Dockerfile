FROM python:3.12.0-alpine@sha256:a5d1738d6abbdff3e81c10b7f86923ebcb340ca536e21e8c5ee7d938d263dba1 AS builder

# Prevent Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE 1

# Keep Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED 1

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ARG PIP_VERSION

# Add requirements file
COPY requirements.txt requirements.txt

# Install requirements
RUN python3 -m venv $VIRTUAL_ENV && \
    pip install --upgrade pip=="${PIP_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt



FROM python:3.12.0-alpine@sha256:a5d1738d6abbdff3e81c10b7f86923ebcb340ca536e21e8c5ee7d938d263dba1

RUN apk add --no-cache firefox && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing geckodriver && \
    ln -s /usr/bin/geckodriver /usr/local/bin/geckodriver && \
    rm -rf /var/cache/apk/* /tmp/*

# Enable custom virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Copy dependencies from previous stage
COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV

# Copy and set the entrypoint bash script
COPY renew.py .
ENTRYPOINT ["python3", "renew.py"]

IMAGE_NAME=simaofsilva/noip-renewer
PYTHON_VERSION=3.9.2
ALPINE_VERSION=3.13

build: build-32 build-64

build-32:
		DOCKER_CLI_EXPERIMENTAL=enabled \
		docker buildx build \
			--build-arg "PYTHON_VERSION=${PYTHON_VERSION}" \
			--push \
			--platform=linux/i386,linux/arm/v7,linux/amd64,linux/arm64/v8 \
			--tag ${IMAGE_NAME}:${PYTHON_VERSION}-slim-buster \
			--file Dockerfile.32bits \
			.

build-64:
		DOCKER_CLI_EXPERIMENTAL=enabled \
		docker buildx build \
			--build-arg "PYTHON_VERSION=${PYTHON_VERSION}" \
			--build-arg "ALPINE_VERSION=${ALPINE_VERSION}" \
			--push \
			--platform=linux/amd64,linux/arm64/v8 \
			--tag ${IMAGE_NAME}:${PYTHON_VERSION}-alpine${ALPINE_VERSION} \
			--tag ${IMAGE_NAME}:latest \
			--file Dockerfile \
			.

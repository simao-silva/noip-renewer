IMAGE_NAME=simaofsilva/noip-renewer
PYTHON_VERSION=3.9.2

build-all: build-32 build-64

build-32:
	DOCKER_CLI_EXPERIMENTAL=enabled \
	docker buildx build \
		--push \
		--platform=linux/i386,linux/arm/v7,linux/amd64,linux/arm64/v8 \
		--tag ${IMAGE_NAME}:${PYTHON_VERSION}-slim-buster \
		--file Dockerfile.32bits \
		.

build-64:
	DOCKER_CLI_EXPERIMENTAL=enabled \
	docker buildx build \
		--push \
		--platform=linux/amd64,linux/arm64/v8 \
		--tag ${IMAGE_NAME}:${PYTHON_VERSION}-alpine3.13 \
		--tag ${IMAGE_NAME}:latest \
		--file Dockerfile \
		.


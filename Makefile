IMAGE_NAME=simaofsilva/noip-renewer
DOCKER_CLI_EXPERIMENTAL=enabled

build-32:
	docker buildx build \
		--push \
		--platform=linux/i386,linux/arm/v7,linux/amd64,linux/arm64/v8 \
		--tag ${IMAGE_NAME}:3.9.1-slim-buster \
		--file Dockerfile.32bits \
		.

build-64:
	docker buildx build \
		--push \
		--platform=linux/amd64,linux/arm64/v8 \
		--tag ${IMAGE_NAME}:3.9.1-alpine3.13 \
		--tag ${IMAGE_NAME}:latest \
		--file Dockerfile \
		.

build: build-32 build-64

build-all: build

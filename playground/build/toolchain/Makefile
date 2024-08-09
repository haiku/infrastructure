VERSION?=1.0
REG_USERNAME?=$(shell gh auth status | sed -rn 's/^.*Logged in to github.com account ([a-zA-Z0-9]*).*/\1/p')
REG_PASSWORD=$(shell gh auth token)
default:
	podman build --no-cache --tag ghcr.io/haiku/toolchain-worker:$(VERSION) .
push:
	podman push ghcr.io/haiku/toolchain-worker:$(VERSION)
build:
	mkdir -p /tmp/buildah
	mkdir -p ${HOME}/srccache
	podman run -it -e CONTAINER_REGISTRY_USERNAME=$(REG_USERNAME) -e CONTAINER_REGISTRY_PASSWORD=$(REG_PASSWORD) -v /tmp/buildah:/var/lib/containers/storage -v ${HOME}/srccache:/toolchains/src ghcr.io/haiku/toolchain-worker:$(VERSION)
enter:
	mkdir -p /tmp/buildah
	podman run -it -v /tmp/buildah:/var/lib/containers/storage -v ${HOME}/srccache:/toolchains/src --entrypoint /bin/bash ghcr.io/haiku/toolchain-worker:$(VERSION)

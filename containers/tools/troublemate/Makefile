VERSION = $(shell cat VERSION | grep -Ev "^#" | tail -1)-development
REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/troublemate:${VERSION} .
enter:
	podman run -it ${REGISTRY}/troublemate:${VERSION} /bin/sh -l
push:
	podman push ${REGISTRY}/troublemate:${VERSION}

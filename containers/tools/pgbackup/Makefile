VERSION = $(shell cat VERSION | grep -Ev "^#" | tail -1)-development
REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/pgbackup:${VERSION} .
push:
	podman push ${REGISTRY}/pgbackup:${VERSION}

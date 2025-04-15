VERSION = 1.3
REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/gitsync:${VERSION} .
push:
	podman push ${REGISTRY}/gitsync:${VERSION}

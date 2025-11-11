VERSION = 3.11.7-1
REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/gerrit:${VERSION} .
test:
	podman run -p 8000:8080 -P ${REGISTRY}/gerrit:${VERSION}
enter:
	podman run -it -P ${REGISTRY}/gerrit:${VERSION} /bin/bash -l
push:
	podman push ${REGISTRY}/gerrit:${VERSION}

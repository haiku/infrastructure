VERSION = latest
REGISTRY = ghcr.io/haiku
default:
	podman build --pull --no-cache --tag ${REGISTRY}/general-worker:${VERSION} .
enter:
	podman run -it ${REGISTRY}/general-worker:${VERSION} /bin/bash -l
push:
	podman push ${REGISTRY}/general-worker:${VERSION}

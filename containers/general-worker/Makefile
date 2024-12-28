VERSION = 19000101
REGISTRY = ghcr.io/haiku
HOST = `uname -m`
default:
	podman build --pull --no-cache --tag ${REGISTRY}/general-worker:${VERSION}-${HOST} .
enter:
	podman run -it ${REGISTRY}/general-worker:${VERSION}-${HOST} /bin/bash -l

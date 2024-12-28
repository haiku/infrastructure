VERSION = 20241228
REGISTRY = ghcr.io/haiku
HOST = `uname -m`
default:
	podman build --pull --no-cache --tag ${REGISTRY}/general-worker:${VERSION}-${HOST} .
enter:
	podman run -it ${REGISTRY}/general-worker:${VERSION} /bin/bash -l
push:
	podman push ${REGISTRY}/general-worker:${VERSION}-${HOST}
push-manifest:
	# Make sure you have all the intended images built and pushed ;-)
	podman manifest create ${REGISTRY}/general-worker:${VERSION} \
		--amend ${REGISTRY}/general-worker:${VERSION}-x86_64 \
		--amend ${REGISTRY}/general-worker:${VERSION}-aarch64 \

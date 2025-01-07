VERSION = $(shell cat VERSION | grep -Ev "^#" | tail -1)-development
REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/www-build:${VERSION} .
test:
	podman kill www-build-test || true
	podman run -d --replace --name www-build-test -P ${REGISTRY}/www-build:$(VERSION)
	@echo "http://`podman port www-build-test 80 | sed 's/0.0.0.0/127.0.0.1/'`"

VERSION = $(shell cat VERSION | grep -Ev "^#" | tail -1)-development
REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/errorku:${VERSION} .
test:
	podman kill errorku-test || true
	podman run -d --replace --name errorku-test -P ${REGISTRY}/errorku:$(VERSION)
	@echo "http://`podman port errorku-test 80 | sed 's/0.0.0.0/127.0.0.1/'`"

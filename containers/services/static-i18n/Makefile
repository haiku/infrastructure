VERSION = $(shell cat VERSION | grep -Ev "^#" | tail -1)-development
REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/static-i18n:${VERSION} .
test:
	podman kill static-i18n-test || true
	podman run -d --replace --name static-i18n-test -P ${REGISTRY}/static-i18n:$(VERSION)
	@echo "http://`podman port static-i18n-test 80 | sed 's/0.0.0.0/127.0.0.1/'`"

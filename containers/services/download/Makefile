VERSION = $(shell cat VERSION | grep -Ev "^#" | tail -1)-development
REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/download:${VERSION} .
test:
	docker kill download-test || true
	podman run -d --replace --name download-test -v ./config.toml:/config.toml -e CONFIG_PATH=/config.toml -P ${REGISTRY}/download:$(VERSION)
	@echo "http://`podman port download-test 8080 | sed 's/0.0.0.0/127.0.0.1/'`"

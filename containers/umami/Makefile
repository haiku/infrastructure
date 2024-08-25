VERSION = postgresql-latest
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/umami:${VERSION} .
push:
	docker push ${REGISTRY}/umami:${VERSION}

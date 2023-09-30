VERSION = 1.6.0-pypy
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/trac:${VERSION} .
push:
	docker push ${REGISTRY}/trac:${VERSION}

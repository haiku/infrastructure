REGISTRY = ghcr.io/haiku
VERSION = 1.4.3
default:
	docker build --no-cache --tag ${REGISTRY}/trac:${VERSION} .
push:
	docker push ${REGISTRY}/trac:${VERSION}

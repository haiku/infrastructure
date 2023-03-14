VERSION = 1.2.3-5
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/cgit:${VERSION} .
push:
	docker push ${REGISTRY}/cgit:${VERSION}

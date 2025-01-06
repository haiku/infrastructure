VERSION = 1.2
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/gitsync:${VERSION} .
push:
	docker push ${REGISTRY}/gitsync:${VERSION}

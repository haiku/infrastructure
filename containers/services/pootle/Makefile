VERSION = 2.7.6-1
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/pootle:${VERSION} .
push:
	docker push ${REGISTRY}/pootle:${VERSION}

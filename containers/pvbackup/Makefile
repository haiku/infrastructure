VERSION = 1.2
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/pvbackup:${VERSION} .
push:
	docker push ${REGISTRY}/pvbackup:${VERSION}

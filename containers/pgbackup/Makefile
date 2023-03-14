VERSION = 1.0
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/pgbackup:${VERSION} .
push:
	docker push ${REGISTRY}/pgbackup:${VERSION}

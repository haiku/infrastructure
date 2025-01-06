VERSION = latest
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/www-build:${VERSION} .
push:
	docker push ${REGISTRY}/www-build:${VERSION}
test:
	docker run -P ${REGISTRY}/www-build:${VERSION}

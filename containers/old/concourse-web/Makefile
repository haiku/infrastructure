VERSION = 7.6.0
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/concourse-web:${VERSION} .
push:
	docker push ${REGISTRY}/concourse-web:${VERSION}
test:
	docker run ${REGISTRY}/concourse-web:${VERSION}

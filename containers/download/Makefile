VERSION=20230211
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/download:$(VERSION) .
test:
	docker run -d --name download-test -P ${REGISTRY}/download:$(VERSION)
clean:
	docker stop download-test
	docker rm download-test
push:
	docker push ${REGISTRY}/download:$(VERSION)

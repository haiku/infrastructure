VERSION = 0.2
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/loadingdock:${VERSION} .
test:
	docker run -d --name loadingdock-test -p 2269:22 ${REGISTRY}/loadingdock:${VERSION}
enter:
	docker run -it ${REGISTRY}/loadingdock:${VERSION} /bin/sh -l
clean:
	docker stop loadingdock-test
	docker rm loadingdock-test
push:
	docker push ${REGISTRY}/loadingdock:${VERSION}

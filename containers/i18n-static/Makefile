VERSION = 1
REGISTRY = ghcr.io/haiku

default:
	docker build --no-cache --tag ${REGISTRY}/i18n-static:${VERSION} .
test:
	docker run -d --name i18n-static-test -P ${REGISTRY}/i18n-static:${VERSION}
enter:
	docker run -it ${REGISTRY}/i18n-static:${VERSION} /bin/sh -l
clean:
	docker stop i18n-static-test
	docker rm i18n-static-test
push:
	docker push ${REGISTRY}/i18n-static:${VERSION}

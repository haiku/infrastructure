VERSION = latest
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/downtime:${VERSION} .
test:
	docker run -d --name downtime-test -eNOTICE_TEXT="BAM IT BROKE" -P ${REGISTRY}/downtime:${VERSION}
enter:
	docker run -it ${REGISTRY}/downtime:${VERSION} /bin/sh -l
clean:
	docker stop downtime-test
	docker rm downtime-test
push:
	docker push ${REGISTRY}/downtime:${VERSION}

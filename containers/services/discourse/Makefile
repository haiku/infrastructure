VERSION = 2026.7.0
REGISTRY = ghcr.io/haiku
ENGINE = podman

default:
	${ENGINE} build --layers --no-cache --build-arg VERSION=${VERSION} -t ${REGISTRY}/discourse:${VERSION} .
shell:
	${ENGINE} run -it ${REGISTRY}/discourse:${VERSION} /bin/bash -l
test:
	${ENGINE} kill redis || true
	${ENGINE} kill discourse || true
	${ENGINE} kill postgres || true
	sleep 5
	${ENGINE} rm postgres || true
	${ENGINE} network create discourse || true
	${ENGINE} run -d --name postgres --network discourse -e POSTGRES_PASSWORD=mysecretpassword docker.io/postgres:latest
	${ENGINE} rm redis || true
	${ENGINE} run -d --name redis --network discourse docker.io/redis:latest
	sleep 20
	${ENGINE} rm discourse || true
	${ENGINE} run --rm --network discourse --env-file test.env ${REGISTRY}/discourse:${VERSION} bundle exec rake db:create
	${ENGINE} run -d --name discourse --network discourse -p 8080:80 --env-file test.env ${REGISTRY}/discourse:${VERSION}
clean:
	${ENGINE} kill redis || true
	${ENGINE} kill discourse || true
	${ENGINE} kill postgres || true
	sleep 5
	${ENGINE} rm postgres || true
	${ENGINE} rm redis || true
	${ENGINE} rm discourse || true
push:
	${ENGINE} push ${REGISTRY}/discourse:${VERSION}

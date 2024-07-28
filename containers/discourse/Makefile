VERSION = 3.2.4
REGISTRY = ghcr.io/haiku

default:
	docker build --layers --no-cache --build-arg VERSION=${VERSION} -t ${REGISTRY}/discourse:${VERSION} .
shell:
	docker run -it ${REGISTRY}/discourse:${VERSION} /bin/bash -l
test:
	docker kill redis || true
	docker kill discourse || true
	docker kill postgres || true
	sleep 5
	docker rm postgres || true
	docker network create discourse || true
	docker run -d --name postgres --network discourse -e POSTGRES_PASSWORD=mysecretpassword docker.io/postgres:latest
	docker rm redis || true
	docker run -d --name redis --network discourse docker.io/redis:latest
	sleep 20
	docker rm discourse || true
	docker run --rm --network discourse --env-file test.env ${REGISTRY}/discourse:${VERSION} bundle exec rake db:create
	docker run -d --name discourse --network discourse -P --env-file test.env ${REGISTRY}/discourse:${VERSION}
clean:
	docker kill redis || true
	docker kill discourse || true
	docker kill postgres || true
	sleep 5
	docker rm postgres || true
	docker rm redis || true
	docker rm discourse || true
push:
	docker push ${REGISTRY}/discourse:${VERSION}

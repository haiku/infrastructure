VERSION = 1.6.0-pypy
REGISTRY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REGISTRY}/trac:${VERSION} .
push:
	docker push ${REGISTRY}/trac:${VERSION}
test:
	docker kill trac || true
	docker kill postgres || true
	sleep 5
	# clean up old data in postgres or in the trac volume
	docker volume rm trac-test || true
	docker rm postgres || true
	docker rm trac || true
	# recreate test environment
	docker network create trac || true
	docker run -d --name postgres --network trac -e POSTGRES_PASSWORD=mysecretpassword docker.io/postgres:latest
	sleep 20
	docker volume create trac-test || true
	docker exec -it postgres createdb -U postgres trac
	docker run --rm --network trac --mount type=volume,source=trac-test,target=/var/trac ${REGISTRY}/trac:${VERSION} trac-admin /var/trac/dev.haiku-os.org/ initenv Trac-test postgres://postgres:mysecretpassword@postgres/trac
	docker run -d --name trac --network trac --mount type=volume,source=trac-test,target=/var/trac -p 127.0.0.1:8080:80/tcp ${REGISTRY}/trac:${VERSION}
	docker exec -it trac trac-admin /var/trac/dev.haiku-os.org/ permission add anonymous TRAC_ADMIN

clean:
	docker kill trac || true
	docker kill postgres || true
	sleep 5
	docker rm postgres || true
	docker rm trac || true
	docker volume rm trac-test || true

VERSION = 1.6.1.11-python
REGISTRY = ghcr.io/haiku
ENGINE = podman
default:
	podman build --no-cache --tag ${REGISTRY}/trac:${VERSION} .
push:
	podman push ${REGISTRY}/trac:${VERSION}
test:
	podman kill trac || true
	podman kill postgres || true
	sleep 5
	# clean up old data in postgres or in the trac volume
	podman volume rm trac-test || true
	podman rm postgres || true
	podman rm trac || true
	# recreate test environment
	podman network create trac || true
	podman run -d --name postgres --network trac -e POSTGRES_PASSWORD=mysecretpassword docker.io/postgres:latest
	sleep 10
	podman volume create trac-test || true
	podman exec -it postgres createdb -U postgres trac
	podman run --rm --network trac --mount type=volume,source=trac-test,target=/var/trac ${REGISTRY}/trac:${VERSION} trac-admin /var/trac/dev.haiku-os.org/ initenv Trac-test postgres://postgres:mysecretpassword@postgres/trac
	podman run --rm -d --name trac --network trac --mount type=volume,source=trac-test,target=/var/trac -p 127.0.0.1:8080:80/tcp ${REGISTRY}/trac:${VERSION}
	podman exec -it trac trac-admin /var/trac/dev.haiku-os.org/ permission add anonymous TRAC_ADMIN

clean:
	podman kill trac || true
	podman kill postgres || true
	sleep 5
	podman rm postgres || true
	podman rm trac || true
	podman volume rm trac-test || true

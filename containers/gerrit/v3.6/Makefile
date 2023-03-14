VERSION = 3.6.3-1
default:
	podman build --no-cache --tag docker.io/haiku/gerrit:${VERSION} .
test:
	podman run -p 8000:8080 -P docker.io/haiku/gerrit:${VERSION}
enter:
	podman run -it -P docker.io/haiku/gerrit:${VERSION} /bin/bash -l
push:
	podman push docker.io/haiku/gerrit:${VERSION}

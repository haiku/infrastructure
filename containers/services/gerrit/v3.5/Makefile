VERSION = 3.5.5
default:
	podman build --no-cache --tag docker.io/haiku/gerrit:${VERSION} .
test:
	podman run -P docker.io/haiku/gerrit:${VERSION}
enter:
	podman run -it -P docker.io/haiku/gerrit:${VERSION} /bin/bash -l
push:
	podman push docker.io/haiku/gerrit:${VERSION}

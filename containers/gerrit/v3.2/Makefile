default:
	podman build --no-cache --tag docker.io/haiku/gerrit:3.2.10 .
test:
	podman run -P docker.io/haiku/gerrit:3.2.10
enter:
	podman run -it -P docker.io/haiku/gerrit:3.2.10 /bin/bash -l
push:
	podman push docker.io/haiku/gerrit:3.2.10

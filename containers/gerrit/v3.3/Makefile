default:
	podman build --no-cache --tag docker.io/haiku/gerrit:3.3.8 .
test:
	podman run -P docker.io/haiku/gerrit:3.3.8
enter:
	podman run -it -P docker.io/haiku/gerrit:3.3.8 /bin/bash -l
push:
	podman push docker.io/haiku/gerrit:3.3.8

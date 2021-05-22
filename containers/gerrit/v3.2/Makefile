default:
	podman build --no-cache --tag docker.io/haiku/gerrit:3.2.10 .
test:
	podman run -P docker.io/haiku/gerrit:3.2.10
push:
	podman push docker.io/haiku/gerrit:3.2.10

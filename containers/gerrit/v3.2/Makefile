default:
	podman build --no-cache --tag docker.io/haiku/gerrit:3.2 .
test:
	podman run -P docker.io/haiku/gerrit:3.2
push:
	posman push docker.io/haiku/gerrit:3.2

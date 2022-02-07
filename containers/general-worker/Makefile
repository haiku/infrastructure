default:
	podman build --pull --no-cache --tag docker.io/haiku/general-worker:latest .
enter:
	podman run -it docker.io/haiku/general-worker:latest /bin/bash -l
push:
	podman push docker.io/haiku/general-worker:latest

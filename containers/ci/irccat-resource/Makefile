REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/irccat-resource:latest .
push:
	podman push ${REGISTRY}/irccat-resource:latest

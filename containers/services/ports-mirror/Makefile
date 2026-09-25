REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/ports-mirror:latest .
test:
	podman run -d --env-file test_s3_secrets ${REGISTRY}/ports-mirror:latest
push:
	podman push ${REGISTRY}/ports-mirror:latest

REGISTRY = ghcr.io/haiku
default:
	podman build --no-cache --tag ${REGISTRY}/ports-mirror:latest .
test:
	podman run --env-file test_s3_secrets ${REGISTRY}/ports-mirror:latest 2>&1 | tee results.json
push:
	podman push ${REGISTRY}/ports-mirror:latest

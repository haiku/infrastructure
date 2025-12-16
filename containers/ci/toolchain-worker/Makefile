BRANCH?=master
default:
	podman build --pull --no-cache --build-arg HAIKU_CHECKOUT=${BRANCH} --build-arg BUILDTOOLS_CHECKOUT=${BRANCH} -t ghcr.io/haiku/toolchain-worker-${BRANCH}:latest .

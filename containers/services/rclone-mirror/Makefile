VERSION = 3.15-3
REPOSITORY = ghcr.io/haiku
default:
	docker build --no-cache --tag ${REPOSITORY}/rclone-mirror:${VERSION} .
push:
	docker push ${REPOSITORY}/rclone-mirror:${VERSION}
enter:
	docker run -it ${REPOSITORY}/rclone-mirror:${VERSION} /bin/bash -l
clean:
	docker stop rclone-test || true
	docker rm rclone-test || true
test:
	docker run --privileged --name rclone-test --env-file TEST_ENV ${REPOSITORY}/rclone-mirror:${VERSION}

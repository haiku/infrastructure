VERSION = 3.15-3
default:
	docker build --no-cache --tag docker.io/haiku/rclone-mirror:${VERSION} .
push:
	docker push docker.io/haiku/rclone-mirror:${VERSION}
enter:
	docker run -it docker.io/haiku/rclone-mirror:${VERSION} /bin/bash -l
clean:
	docker stop rclone-test || true
	docker rm rclone-test || true
test:
	docker run --privileged --name rclone-test --env-file TEST_ENV docker.io/haiku/rclone-mirror:${VERSION}

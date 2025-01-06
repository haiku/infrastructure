default:
	docker build --no-cache --tag docker.io/haiku/rclonefs:3.15-1 .
push:
	docker push docker.io/haiku/rclonefs:3.15-1
enter:
	docker run -it docker.io/haiku/rclonefs:3.15-1 /bin/bash -l
clean:
	docker stop rclone-test || true
	docker rm rclone-test || true
test:
	docker run --privileged --name rclone-test --env-file TEST_ENV docker.io/haiku/rclonefs:3.15-1

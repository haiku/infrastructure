default:
	docker build --no-cache --tag docker.io/haiku/downloads:latest .
test:
	docker run -d --name downloads-test docker.io/haiku/downloads:latest
clean:
	docker stop downloads-test
	docker rm downloads-test
push:
	docker push docker.io/haiku/downloads:latest

default:
	docker build --no-cache --tag docker.io/haiku/download:latest .
test:
	docker run -d --name download-test docker.io/haiku/download:latest
clean:
	docker stop download-test
	docker rm download-test
push:
	docker push docker.io/haiku/download:latest

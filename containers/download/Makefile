default:
	docker build --no-cache --tag docker.io/haiku/download:20220331 .
test:
	docker run -d --name download-test -P docker.io/haiku/download:20220331
clean:
	docker stop download-test
	docker rm download-test
push:
	docker push docker.io/haiku/download:20220331

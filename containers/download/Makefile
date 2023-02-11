VERSION=20230211
default:
	docker build --no-cache --tag docker.io/haiku/download:$(VERSION) .
test:
	docker run -d --name download-test -P docker.io/haiku/download:$(VERSION)
clean:
	docker stop download-test
	docker rm download-test
push:
	docker push docker.io/haiku/download:$(VERSION)

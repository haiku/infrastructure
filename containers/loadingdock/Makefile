default:
	docker build --no-cache --tag docker.io/haiku/loadingdock:latest .
test:
	docker run -d --name loadingdock-test -p 2269:22 docker.io/haiku/loadingdock:latest
enter:
	docker run -it docker.io/haiku/loadingdock:latest /bin/sh -l
clean:
	docker stop loadingdock-test
	docker rm loadingdock-test
push:
	docker push docker.io/haiku/loadingdock:latest

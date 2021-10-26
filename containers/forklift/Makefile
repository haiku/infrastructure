default:
	docker build --no-cache --tag docker.io/haiku/forklift:latest .
enter:
	docker run -it docker.io/haiku/forklift:latest /bin/sh -l
clean:
	docker stop forklift-test
	docker rm forklift-test
push:
	docker push docker.io/haiku/forklift:latest

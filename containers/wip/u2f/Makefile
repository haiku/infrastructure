default:
	docker build --no-cache --tag docker.io/haiku/u2f:latest .
push:
	docker push docker.io/haiku/u2f:latest
clean:
	docker kill u2f-test || true
	docker rm u2f-test
test:
	docker run -P --name u2f-test docker.io/haiku/u2f:latest

default:
	docker build --no-cache --tag docker.io/haiku/nginx:latest .
push:
	docker push docker.io/haiku/nginx:latest
clean:
	docker stop nginx-test || true
	docker rm nginx-test || true
test:
	docker run --name nginx-test docker.io/haiku/nginx:latest

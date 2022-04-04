default:
	docker build --no-cache --tag docker.io/haiku/www-build:latest .
push:
	docker push docker.io/haiku/www-build:latest
test:
	docker run -P docker.io/haiku/www-build:latest

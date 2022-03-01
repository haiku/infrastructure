default:
	docker build --no-cache --tag docker.io/haiku/i18n-static:latest .
test:
	docker run -d --name i18n-static-test -P docker.io/haiku/i18n-static:latest
enter:
	docker run -it docker.io/haiku/i18n-static:latest /bin/sh -l
clean:
	docker stop i18n-static-test
	docker rm i18n-static-test
push:
	docker push docker.io/haiku/i18n-static:latest

default:
	docker build --no-cache --tag docker.io/haiku/downtime:latest .
test:
	docker run -d --name downtime-test -eNOTICE_TEXT="BAM IT BROKE" -P docker.io/haiku/downtime:latest
enter:
	docker run -it docker.io/haiku/downtime:latest /bin/sh -l
clean:
	docker stop downtime-test
	docker rm downtime-test
push:
	docker push docker.io/haiku/downtime:latest

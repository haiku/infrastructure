default:
	docker build -t docker.io/haiku/discourse:latest .
shell:
	docker run -it docker.io/haiku/discourse:latest /bin/bash -l
test:
	docker kill redis || true
	docker kill discourse || true
	docker kill postgres || true
	sleep 5
	docker rm postgres || true
	docker run -d --name postgres -e POSTGRES_PASSWORD=mysecretpassword postgres:latest
	docker rm redis || true
	docker run -d --name redis redis:latest
	sleep 20
	docker rm discourse || true
	docker run -d --name discourse --env-file test.env docker.io/haiku/discourse:latest

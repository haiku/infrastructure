default:
	docker build --no-cache -t docker.io/haiku/discourse:latest .
shell:
	docker run -it docker.io/haiku/discourse:latest /bin/bash -l
test:
	docker kill redis || true
	docker kill discourse || true
	docker kill postgres || true
	sleep 5
	docker rm postgres || true
	docker network create discourse || true
	docker run -d --name postgres --network discourse -e POSTGRES_PASSWORD=mysecretpassword postgres:latest
	docker rm redis || true
	docker run -d --name redis --network discourse redis:latest
	sleep 20
	docker rm discourse || true
	docker run --rm --network discourse --env-file test.env docker.io/haiku/discourse:latest bundle exec rake db:create
	docker run -d --name discourse --network discourse -P --env-file test.env docker.io/haiku/discourse:latest
clean:
	docker kill redis || true
	docker kill discourse || true
	docker kill postgres || true
	sleep 5
	docker rm postgres || true
	docker rm redis || true
	docker rm discourse || true
push:
	docker push docker.io/haiku/discourse:latest

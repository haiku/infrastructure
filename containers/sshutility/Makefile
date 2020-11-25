default:
	docker build --no-cache --tag docker.io/haiku/sshutility:latest .
test:
	docker run -d --name sshutility-test -P docker.io/haiku/sshutility
clean:
	docker stop sshutility-test
	docker rm sshutility-test
push:
	docker push docker.io/haiku/sshutility
